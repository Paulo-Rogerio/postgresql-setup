### Start Docker Compose

Executar o ***docker-compose*** para iniciar os containers.

```bash
sh docker-compose/restart.sh
```

### Gerar Dados / Migrar Cluster

Para fins didáticos foi criado esse setup:

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

### Informações Cluster

Como ambiente e dockerizado foi definido que:

```yaml
5433 => primary
5434 => replica
```