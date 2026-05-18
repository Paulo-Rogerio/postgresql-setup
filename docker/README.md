# Postgresql Setup Replicação Lógica

O propósito deste laboratório, e entender como usar **Replicação Lógica** para minimizar **downtime** no Upgrade de versões em um cluster PostgreSQL.


[1) Setup Docker Compose](#1-setup-docker-compose)

[2) Setup Replicação Lógica](#2-setup-replicação-lógica)

[3) Setup Informações do Cluster](#3-setup-informações-do-cluster)

[4) Replicação Lógica Vs BigTables](#4-replicação-lógica-vs-bigtables)

[5) Roles e Permissões](#5-roles-e-permissões)

### 1) Setup Docker Compose

Executar o ***docker-compose*** para iniciar os containers.

```bash
sh docker-compose/restart.sh
```

### 2) Setup Replicação Lógica

Para fins didáticos foi criado esse setup.

- Criar / Definir estrutra do Banco
- Criar Roles e Permissões
- Criar / Definir replicação Lógica
- Syncronização / Replicação dos Dados 
- Promoção do Novo Cluster

```bash
sh generate-data/01-create-infra.sh
sh generate-data/02-create-cluster.sh
sh generate-data/03-manager-cluster.sh
```

### 3) Setup Informações do Cluster 

Como ambiente e dockerizado foi definido que:

```yaml
5433 => primary
5434 => replica
```

### 4) Replicação Lógica Vs BigTables

Quando se tem um cluster muito grande, na casa dos **TB**, a replicação Lógica, pode trazer alguns problemas. Um dos principais é que enquanto a replicação acontece, pode-se acumular uma quantidade grande **WALS**, ter um **Lag de Replicação enorme** e um processo sync mais lento.

Pensando nesse problema, foi desenhado um **setup simples**, onde carrega-se a carga de dados mais pesada **( no cenário 3 TB de uma determinada tabela)** antes mesmo de iniciar a replicação lógica. 

Esse tipo de abordagem, permite que a replicação trabalhe de forma incremental. 


De forma prática
Temos uma Tabela: `3 TB`
Taxa de mudança: `20 GB/dia`
Dump/import demora: `10 horas`

Nesse caso:
A replicação lógica precisará aplicar apenas: `~ 8 GB de delta` e não 3 TB.

Para esse cenário, deve-se respeitar uma sequencia lógica dos eventos, por isso eles foram 
encadeados de forma sequêncial, para melhor entendimento.

```bash
cd generate-data/bigtables
```

No setup, existe um script `03-snapshot.sh` isso nos garante um dump consistente com WAL lógico. Nessa etapa a subscription deve exatamente após esse ponto. 

Enquanto se faz dump/import:

- INSERTs acontecem;
- UPDATEs acontecem;
- DELETEs acontecem.

Como garantir que o dump e os WALs representam o MESMO ponto no tempo?

`pg_export_snapshot()` => uma fotografia consistente do banco, principalmente se estiver usando  `pg_dump -Fd -j 16` cada worker do pg_dump pode enxergar momentos diferentes.

SNAPSHOT CONSISTENTE
        +
WAL lógico a partir daquele ponto.

Essa consitencia e ordenamento é levado em consideração pelo subscriber que aplica WALs:
`A -> B -> C -> D`

No laboratório, ao executar `03-snapshot.sh` seu terminal ficará preso, abra outra aba e continue o próximo script que o `04-dump-restore.sh`, quando finalizado, o terminal preso pode ser encerrado **( Ctrl + c)**.


### 5) Roles e Permissões

Essa instrução ***SQL***, te permite criar dinamicamente a estrutura do seu banco **PostgreSQL**. Ela pode ser muito útil, principalmente se vinculado a sua ferrameta de automação, principalmente pelo fato do script abaixo gerar dinamicamente **senhas**, entao plugar um cofre de senha como **Vault** seria totalmente possível.


```sql
cat > infra.sql <<EOF
--\prompt 'Service name: ' service_name
\set service_dml_role :service_name'-dml'
\set service_adm_role :service_name'-admin'
\set service_ddl_role :service_name'-ddl'
\set service_ro_role :service_name'-ro'
\set service_app_user :service_name'-app'
\set service_migration_user :service_name'-migration'

-- Gera uma senha para o service_app_user
SELECT string_agg(chars, '' ORDER BY random()) AS pwd
FROM (
    SELECT
        unnest(
            array(SELECT * FROM unnest(upper||upper||upper||upper||upper) ORDER BY random() LIMIT 3+floor(random()*3)::int)
            || array(SELECT * FROM unnest(lower||lower||lower||lower||lower) ORDER BY random() LIMIT 3+floor(random()*3)::int)
            || array(SELECT * FROM unnest(special||special) ORDER BY random() LIMIT 2+floor(random()*2)::int)
            || array(SELECT * FROM unnest(digit||digit) ORDER BY random() LIMIT 2+floor(random()*4)::int)
        )
        AS chars
    FROM (
        SELECT
            array_agg(chr(i)) FILTER(WHERE chr(i) ~ '[A-Z]') AS upper,
            array_agg(chr(i)) FILTER(WHERE chr(i) ~ '[a-z]') AS lower,
            array_agg(chr(i)) FILTER(WHERE chr(i) ~ '[0-9]') AS digit,
            array_agg(chr(i)) FILTER(WHERE chr(i) ~ '[!#$%&*+-/;?]') AS special
        FROM
            generate_series(33, 122) AS t1(i)
    ) t2
) t3 \gset service_app_user_

-- Gera uma senha para o service_migration_user
SELECT string_agg(chars, '' ORDER BY random()) AS pwd
FROM (
    SELECT
        unnest(
            array(SELECT * FROM unnest(upper||upper||upper||upper||upper) ORDER BY random() LIMIT 3+floor(random()*3)::int)
            || array(SELECT * FROM unnest(lower||lower||lower||lower||lower) ORDER BY random() LIMIT 3+floor(random()*3)::int)
            || array(SELECT * FROM unnest(special||special) ORDER BY random() LIMIT 2+floor(random()*2)::int)
            || array(SELECT * FROM unnest(digit||digit) ORDER BY random() LIMIT 2+floor(random()*4)::int)
        )
        AS chars
    FROM (
        SELECT
            array_agg(chr(i)) FILTER(WHERE chr(i) ~ '[A-Z]') AS upper,
            array_agg(chr(i)) FILTER(WHERE chr(i) ~ '[a-z]') AS lower,
            array_agg(chr(i)) FILTER(WHERE chr(i) ~ '[0-9]') AS digit,
            array_agg(chr(i)) FILTER(WHERE chr(i) ~ '[!#$%&*+-/;?]') AS special
        FROM
            generate_series(33, 122) AS t1(i)
    ) t2
) t3 \gset service_migration_user_

\echo 'Creating service ':service_name' with ':service_dml_role', ':service_ro_role', ':service_app_user', ':service_migration_user

BEGIN;
-- Role that owns all objects
\echo 'Creating role ':"service_name"
CREATE ROLE :"service_name" LOGIN;

-- Admin role
\echo 'Creating role ':"service_adm_role"
CREATE ROLE :"service_adm_role" ROLE :"USER" IN ROLE :"service_name" NOINHERIT NOLOGIN;

-- DML role
\echo 'Creating role ':"service_dml_role"
CREATE ROLE :"service_dml_role" NOLOGIN;

-- DDL role
\echo 'Creating role ':"service_ddl_role"
CREATE ROLE :"service_ddl_role"  IN ROLE :"service_dml_role", :"service_adm_role" NOLOGIN;

-- Read-only role
\echo 'Creating role ':"service_ro_role"
CREATE ROLE :"service_ro_role" NOLOGIN;
COMMIT;

-- App user
\echo 'Creating user ':"service_app_user"' with password ':"service_app_user_pwd"
CREATE ROLE :"service_app_user" LOGIN PASSWORD :'service_app_user_pwd' IN ROLE :"service_dml_role";

-- Migration user
\echo 'Creating user ':"service_migration_user"' with password ':"service_migration_user_pwd"
CREATE ROLE :"service_migration_user" LOGIN PASSWORD :'service_migration_user_pwd' IN ROLE :"service_ddl_role";

-- Reset Password
\echo 'Reset Password'
ALTER ROLE postgres WITH PASSWORD 'postgres';

-- The database
\echo 'Creating database ':"service_name"
CREATE DATABASE :"service_name" OWNER :"service_name";

-- Setup permissions
\echo 'Setting up permissions'
\c :"service_name"
BEGIN;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
REVOKE CREATE ON DATABASE :"service_name" FROM PUBLIC;
GRANT CREATE ON SCHEMA public TO :"service_name";

SET ROLE :"service_name";
ALTER DEFAULT PRIVILEGES GRANT SELECT ON TABLES TO :"service_ro_role";
ALTER DEFAULT PRIVILEGES GRANT SELECT ON SEQUENCES TO :"service_ro_role";
ALTER DEFAULT PRIVILEGES GRANT SELECT,INSERT,UPDATE,DELETE ON TABLES TO :"service_dml_role";
ALTER DEFAULT PRIVILEGES GRANT USAGE, SELECT ON SEQUENCES TO :"service_dml_role";
ALTER DEFAULT PRIVILEGES GRANT EXECUTE ON FUNCTIONS TO :"service_dml_role";
ALTER DEFAULT PRIVILEGES GRANT USAGE ON SCHEMAS TO :"service_dml_role", :"service_ro_role";

GRANT SELECT ON ALL TABLES IN SCHEMA public TO :"service_ro_role";
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO :"service_ro_role";
GRANT SELECT,INSERT,UPDATE,DELETE ON ALL TABLES IN SCHEMA public TO :"service_dml_role";
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO :"service_dml_role";
COMMIT;

SELECT replace(:'service_name', '-', '_') AS schema_name \gset
CREATE SCHEMA IF NOT EXISTS :schema_name;

ALTER DATABASE :"service_name" SET search_path = :schema_name, public;
EOF
```

Uma vez definida, para usa-la seria assim.

```bash
psql -d postgres -v service_name="meu-produto" < infra.sql
```
Isso iria gerar um resultado semelhante a isso.

```bash
Creating service meu-produto with meu-produto-dml, meu-produto-ro, meu-produto-app, meu-produto-migration
BEGIN
Creating role "meu-produto"
CREATE ROLE
Creating role "meu-produto-admin"
CREATE ROLE
Creating role "meu-produto-dml"
CREATE ROLE
Creating role "meu-produto-ddl"
CREATE ROLE
Creating role "meu-produto-ro"
CREATE ROLE
COMMIT
Creating user "meu-produto-app" with password "70aArAPi&B#b"
CREATE ROLE
Creating user "meu-produto-migration" with password "eQ#&5AKmKBjh3x&"
CREATE ROLE
Reset Password
ALTER ROLE
Creating database "meu-produto"
CREATE DATABASE
Setting up permissions
You are now connected to database "meu-produto" as user "postgres".
BEGIN
REVOKE
REVOKE
GRANT
SET
ALTER DEFAULT PRIVILEGES
ALTER DEFAULT PRIVILEGES
ALTER DEFAULT PRIVILEGES
ALTER DEFAULT PRIVILEGES
ALTER DEFAULT PRIVILEGES
ALTER DEFAULT PRIVILEGES
GRANT
GRANT
GRANT
GRANT
COMMIT
CREATE SCHEMA
ALTER DATABASE
```

### Criando Roles Dinamicamente

Procedimento de criar e definir Roles de forma semelhante. Aqui seria interessante vincular a senha do usuario em algum LDAP ou autenticando via certificado.

Mas para título de aprendizagem, vou definir no próprio script a senha.

```bash
cat > roles.sql <<EOF
--\prompt 'Service name: ' service_name
--\prompt 'Minha Role: ' myrole
\set my_role_leitura :myrole'-ro'
\set my_role_escrita :myrole'-rw'
\set service_dml_role :service_name'-dml'
\set service_ro_role :service_name'-ro'

-- Create User Paulo
\echo 'Creating role Leitura ':"my_role_leitura"
CREATE ROLE :"my_role_leitura" LOGIN PASSWORD '123456';

\echo 'Creating role Escrita ':"my_role_escrita"
CREATE ROLE :"my_role_escrita" LOGIN PASSWORD '123456';

-- Grant
BEGIN;
\echo 'Add usuario ':"my_role_escrita" 'no grupo' :"service_dml_role"
GRANT :"service_dml_role" TO :"my_role_escrita";

\echo 'Add usuario ':"my_role_leitura" 'no grupo' :"service_ro_role"
GRANT :"service_ro_role" TO :"my_role_leitura"; 
COMMIT;
EOF
```

Criando as roles dinamicamente.

```bash
psql -d postgres -v service_name="meu-produto" -v myrole="benicio" < roles.sql

psql -d postgres -v service_name="meu-produto" -v myrole="camilla" < roles.sql

psql -d postgres -v service_name="meu-produto" -v myrole="alvaro" < roles.sql

psql -d postgres -v service_name="meu-produto" -v myrole="paulo" < roles.sql


Creating role Leitura "benicio-ro"
CREATE ROLE
Creating role Escrita "benicio-rw"
CREATE ROLE
BEGIN
Add usuario "benicio-rw" no grupo "meu-produto-dml"
GRANT ROLE
Add usuario "benicio-ro" no grupo "meu-produto-ro"
GRANT ROLE
COMMIT
```

### Validando as Permissões - Migrate

Quem pode fazer migrate? Apenas a role **meu-produto-migration**.

```sql
export PGPASSWORD='eQ#&5AKmKBjh3x&' 
psql -h localhost -U 'meu-produto-migration' -d 'meu-produto' 

SET ROLE 'meu-produto';
CREATE TABLE foo(c1 int, c2 timestamp default current_timestamp);


meu-produto=> SET ROLE 'meu-produto';
SET

meu-produto=> CREATE TABLE foo(c1 int, c2 timestamp default current_timestamp);
CREATE TABLE

meu-produto=> \dt foo
            List of relations
   Schema    | Name | Type  |    Owner    
-------------+------+-------+-------------
 meu_produto | foo  | table | meu-produto
(1 row)
```

### Validando as Permissões - Usuario RW

```bash
export PGPASSWORD='123456'
psql -h localhost -U 'paulo-rw' -d 'meu-produto' 
```

```sql
meu-produto=> INSERT INTO foo ( c1,c2 ) VALUES (1,now());
INSERT 0 1

meu-produto=> select * from foo;
 c1 |             c2             
----+----------------------------
  1 | 2026-05-17 11:23:36.371065
(1 row)

meu-produto=> UPDATE foo SET c1  = 2;
UPDATE 1

meu-produto=> select * from foo;
 c1 |             c2             
----+----------------------------
  2 | 2026-05-17 11:23:36.371065
(1 row)
```

Se por algum motivo, o usuario **RW** tentar efetuar migrate?

```sql
meu-produto=> ALTER ROLE "meu-produto-migration" SET ROLE "meu-produto";
ERROR:  permission denied
```

### Validando as Permissões - Usuario RO

Usuário apenas leitura.

```sql
export PGPASSWORD='123456'
psql -h localhost -U 'paulo-ro' -d 'meu-produto'

meu-produto=> select * from foo;
 c1 |             c2             
----+----------------------------
  1 | 2026-05-17 11:23:36.371065
(1 row)

UPDATE foo SET c1  = 2;
ERROR:  permission denied for table foo
```
