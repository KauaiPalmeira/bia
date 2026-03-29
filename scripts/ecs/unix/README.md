# Scripts ECS - BIA

Scripts para deploy e rollback da aplicação BIA no ECS.

## Scripts disponíveis

| Script | Descrição |
|---|---|
| `build.sh` | Build e push da imagem com tag `latest` |
| `deploy.sh` | Deploy simples com `force-new-deployment` |
| `deploy-versionado.sh` | Deploy com tag do commit hash + nova task definition |
| `rollback.sh` | Rollback para uma revisão específica da task definition |

---

## deploy-versionado.sh

Faz build, push da imagem tagueada com o commit hash, registra uma nova task definition e realiza o deploy no ECS.

```bash
# Usa o commit atual do git automaticamente
./deploy-versionado.sh

# Ou passa o hash manualmente
./deploy-versionado.sh a1b2c3d
```

Cada execução gera:
- Uma imagem no ECR com a tag do commit (ex: `bia:a1b2c3d`)
- Uma nova revisão da task definition (ex: `task-def-bia:4`)

---

## rollback.sh

Faz o deploy de uma revisão anterior da task definition.

```bash
./rollback.sh task-def-bia:3
```

Para listar as revisões disponíveis:

```bash
aws ecs list-task-definitions --family-prefix task-def-bia --region us-east-1
```
