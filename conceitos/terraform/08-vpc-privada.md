# VPC Privada — Segurança (serviços fora do alcance público)

## O que é
VPC (Virtual Private Cloud) é a **rede virtual isolada** da AWS. Serviços dentro
da VPC **não são expostos publicamente** — só acessíveis de dentro da rede.
Isso elimina o risco de exposição pública (premissa da spec: já houve tentativa
de invasão no front).

## Para que serve
- **Isolar** front, API e serviços da exposição pública
- **Comunicação interna** pelos nomes dos serviços (sem HTTPS exposto)
- **API Gateway privado** (interface VPC endpoint) — só acessível de dentro da VPC
- **Next.js API** faz as requisições HTTP **sem passar pelo browser** (server-side)

## Arquitetura (etapa 2 da spec)

```
Usuário → Front (Next.js, privado) → API Next (server-side) → API Gateway (privado) → Lambda
                                        ↓ (mesma VPC, nome interno)
                              Click Sign / Zenvia (via Secrets Manager)
```

- Nada fica **visível** ao usuário (nem front, nem API)
- Os serviços se falam pelo **nome interno da VPC** (ex: `api-futurosign.internal`)
- O usuário só interage com a interface final (rotas autenticadas)

## Como configurar (AWS)

```hcl
# Terraform (AWS real)
resource "aws_vpc" "this" { cidr_block = "10.0.0.0/16" }

resource "aws_vpc_endpoint" "apigateway" {
  vpc_id       = aws_vpc.this.id
  service_name = "com.amazonaws.us-east-1.execute-api"
  vpc_endpoint_type = "Interface"
}

resource "aws_security_group" "internal" {
  vpc_id = aws_vpc.this.id
  # rules: permitir apenas trafego interno da VPC
}
```

> **No floci**: a VPC **não é emulada** (EC2 é). O conceito é documentado aqui;
> a validação real acontece na AWS (produção).

## Benefícios de segurança

| Recurso | Impacto |
|---------|---------|
| API Gateway privado | Ninguém externo acessa a API |
| Front privado | Usuário só acessa via fluxo autenticado |
| Nome interno | Sem HTTPS público — sem scanner/ataque externo |
| Next.js server-side | Requisições fora do browser (sem expor chaves) |

## Resumo
- **Tudo na mesma VPC** → nada visível
- **Comunicação por nome interno** → sem link HTTPS exposto
- **Next.js API** → requisições sem passar pelo browser
- Validação real: AWS (floci não emula VPC)
