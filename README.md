# Aeon Flow — Gestão de Reservas de Salas de Reunião

Sistema full-stack para criar, consultar, atualizar e cancelar reservas de salas de reunião. O backend expõe uma API REST em Ruby (Hanami) e o frontend é uma SPA server-rendered em Deno/Fresh.

## Stack

| Camada | Tecnologia |
|--------|------------|
| Backend | Ruby 3.3+, Hanami::API, ROM-SQL, SQLite |
| Frontend | Deno, Fresh, Preact, Tailwind CSS |
| Auth | JWT (HS256) + BCrypt |
| Docs | Swagger OpenAPI 3.0 em `/docs` |

## Como Executar

### Pré-requisitos

- Ruby **3.3.0** (recomendado via `asdf`; evite Ruby 3.4 dev — incompatível com `sqlite3`)
- Bundler
- Deno

### Backend

```bash
cd backend
asdf local ruby 3.3.0   # opcional, mas recomendado
bundle install
ENVIRONMENT=development bundle exec rake db:migrate
ENVIRONMENT=development bundle exec rake db:seed
bin/dev
```

- API: `http://localhost:9292`
- Swagger UI: `http://localhost:9292/docs`
- OpenAPI JSON: `http://localhost:9292/api-docs/swagger.json`

**Credenciais padrão (seed):** `admin@aeonflow.com` / `admin123`

### Frontend

```bash
cd frontend
API_URL=http://localhost:9292/api/v1 deno task start
```

Acesse `http://localhost:8000`. Faça login em `/login` para operações de escrita.

## Autenticação

| Tipo de rota | Autenticação |
|--------------|--------------|
| `GET /api/v1/rooms` e sub-recursos de leitura | Pública |
| `POST /api/v1/auth/login` | Pública |
| `POST`, `PUT`, `DELETE` | Requer `Authorization: Bearer <token>` |

```bash
# Obter token
curl -X POST http://localhost:9292/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@aeonflow.com","password":"admin123"}'

# Usar token
curl -X POST http://localhost:9292/api/v1/rooms \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <token>" \
  -d '{"name":"Sala Gamma","capacity":15,"location":"Andar 3"}'
```

## Endpoints da API

Base URL: `/api/v1`

### Autenticação

| Método | Rota | Descrição |
|--------|------|-----------|
| `POST` | `/auth/login` | Autentica e retorna `{ token, user }` |

### Salas

| Método | Rota | Auth | Descrição |
|--------|------|------|-----------|
| `GET` | `/rooms` | — | Lista salas. Query: `?search=nome` |
| `POST` | `/rooms` | JWT | Cria sala (`name`, `capacity`, `location`) |
| `GET` | `/rooms/{id}` | — | Detalhes de uma sala |
| `PUT` | `/rooms/{id}` | JWT | Atualiza sala |
| `DELETE` | `/rooms/{id}` | JWT | Exclui sala (cascade nas reservas) |

### Reservas

| Método | Rota | Auth | Descrição |
|--------|------|------|-----------|
| `GET` | `/rooms/{room_id}/reservations` | — | Lista reservas. Query: `status`, `start_time`, `end_time`, `search` |
| `POST` | `/rooms/{room_id}/reservations` | JWT | Cria reserva |
| `GET` | `/rooms/{room_id}/reservations/{id}` | — | Detalhes de uma reserva |
| `PUT` | `/rooms/{room_id}/reservations/{id}` | JWT | Atualiza reserva |
| `DELETE` | `/rooms/{room_id}/reservations/{id}` | JWT | Cancela reserva (soft delete → `cancelled`) |

### Códigos de resposta relevantes

| Código | Situação |
|--------|----------|
| `201` | Recurso criado |
| `204` | Exclusão/cancelamento bem-sucedido |
| `401` | Token ausente ou inválido |
| `404` | Recurso não encontrado |
| `409` | Conflito de horário (sala indisponível) |
| `422` | Erro de validação ou regra de negócio |

## Regras de Negócio

1. **Disponibilidade** — Uma sala não pode ter duas reservas ativas (não canceladas) no mesmo intervalo de tempo.
2. **Validação de salas** — Nome entre 1 e 100 caracteres; capacidade deve ser um inteiro positivo.
3. **Reservas no futuro** — Na criação, `start_time` deve ser posterior ao momento atual.
4. **Intervalo válido** — `end_time` deve ser posterior a `start_time`.
5. **Cancelamento** — Só é permitido com pelo menos 24 horas de antecedência em relação ao `start_time`.

## Banco de Dados (SQLite)

### Tabela `rooms`

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | VARCHAR (UUID) | Chave primária |
| `name` | VARCHAR | Nome da sala |
| `capacity` | INTEGER | Capacidade |
| `location` | VARCHAR | Localização |

### Tabela `reservations`

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | VARCHAR (UUID) | Chave primária |
| `room_id` | VARCHAR (UUID) | FK → `rooms.id` (cascade) |
| `start_time` | DATETIME | Início da reserva |
| `end_time` | DATETIME | Término da reserva |
| `description` | TEXT | Descrição opcional |
| `responsible` | VARCHAR(100) | Responsável |
| `status` | VARCHAR | `confirmed`, `pending` ou `cancelled` |

### Tabela `users`

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | VARCHAR (UUID) | Chave primária |
| `email` | VARCHAR | E-mail único |
| `password_digest` | VARCHAR | Hash BCrypt |
| `name` | VARCHAR | Nome do usuário |

## Arquitetura

O projeto segue **Clean Architecture** com **DDD** (bounded contexts):

| Padrão | Backend (Ruby) | Frontend (Deno/Fresh) |
|--------|----------------|------------------------|
| Use Cases | `application/use_cases/` | `domain/usecases/` + `application/usecases/` |
| Entities | `domain/entities/` | `domain/entities/` |
| Repositories | `application/repositories/` + `infrastructure/` | Adapters HTTP (`HttpClient`) |
| DI / Factory | `dry-container` (`AppContainer`) | `factories/` |
| Result type | `dry-monads` (Success/Failure) | `Either` (Left/Right) |
| Unit of Work | `SharedDomain::Infrastructure::UnitOfWork` | — |
| Auth | JWT middleware + BCrypt | Cookie HttpOnly + Bearer header |
| Resilience | Transações + rollback | Retry com backoff no Axios |

### Bounded Contexts (Backend)

```
src/lib/
├── shared_domain/   # kernel: Entity, Validation, ROM, UnitOfWork
├── rooms/           # CRUD de salas
├── reservations/    # CRUD de reservas + regras de negócio
└── auth/            # autenticação JWT
```

### Rotas do Frontend

| Rota | Descrição |
|------|-----------|
| `/` | Redireciona para `/rooms` |
| `/login` | Autenticação |
| `/rooms` | Listagem e busca de salas |
| `/rooms/new` | Criar sala |
| `/rooms/[id]` | Detalhes e exclusão |
| `/rooms/[id]/edit` | Editar sala |
| `/rooms/[id]/reservations` | Listagem com filtros |
| `/rooms/[id]/reservations/new` | Nova reserva |
| `/rooms/[id]/reservations/[reservationId]` | Detalhes e cancelamento |
| `/rooms/[id]/reservations/[reservationId]/edit` | Editar reserva |

## Requisitos Funcionais

| # | Requisito | Status |
|---|-----------|--------|
| 1 | Criação de salas | Implementado |
| 2 | Atualização de salas | Implementado |
| 3 | Visualização de salas | Implementado |
| 4 | Criação de reservas | Implementado |
| 5 | Atualização de reservas | Implementado |
| 6 | Visualização de reservas | Implementado |
| 7 | Cancelamento de reservas | Implementado |
| 8 | Filtragem e busca | Implementado |

## Requisitos Não Funcionais

| # | Requisito | Como é atendido |
|---|-----------|-----------------|
| 1 | Performance (< 2s) | SQLite local + queries indexadas |
| 2 | Escalabilidade | Arquitetura stateless; API pode escalar horizontalmente |
| 3 | Segurança | JWT + BCrypt; middleware de auth nas mutações |
| 4 | Usabilidade | UI responsiva com Tailwind; navegação clara |
| 5 | Manutenibilidade | Clean Architecture, bounded contexts, testes unitários |

## Testes

```bash
cd backend
ENVIRONMENT=test bundle exec rspec
```

## Variáveis de Ambiente

### Backend (`backend/.env.dev`)

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `PORT` | `9292` | Porta do servidor |
| `ENVIRONMENT` | `development` | Ambiente (`development` / `test`) |
| `JWT_SECRET` | — | Chave secreta para assinatura JWT |

### Frontend

| Variável | Padrão | Descrição |
|----------|--------|-----------|
| `API_URL` | `http://localhost:9292/api/v1` | URL base da API |
