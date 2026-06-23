# frozen_string_literal: true

require 'swagger/blocks'

require_relative '../initializers/environment'

module App
  module Docs
    module SwaggerDocs
      include Swagger::Blocks

      module_function

      def generate_docs
        swagger_root = Swagger::Blocks.build_root_json([self])
        JSON.pretty_generate(swagger_root)
      end

      swagger_component do
        security_scheme :bearerAuth do
          key :type, :http
          key :scheme, :bearer
          key :bearerFormat, :JWT
          key :description, 'Token JWT obtido via POST /api/v1/auth/login'
        end

        schema :Error do
          key :type, :object
          property :error do
            key :type, :string
            key :example, 'Resource not found'
          end
        end

        schema :ValidationErrors do
          key :type, :object
          property :errors do
            key :type, :array
            items do
              key :type, :string
            end
            key :example, ['name must be filled']
          end
        end

        schema :RoomInput do
          key :type, :object
          key :required, %i[name capacity location]
          property :name do
            key :type, :string
            key :maxLength, 100
            key :description, 'Nome da sala (1–100 caracteres)'
            key :example, 'Sala Alpha'
          end
          property :capacity do
            key :type, :integer
            key :minimum, 1
            key :description, 'Capacidade máxima da sala'
            key :example, 10
          end
          property :location do
            key :type, :string
            key :description, 'Localização física da sala'
            key :example, 'Andar 1 - Ala Norte'
          end
        end

        schema :RoomOutput do
          key :type, :object
          property :id do
            key :type, :string
            key :format, :uuid
            key :description, 'Identificador único da sala'
            key :example, '550e8400-e29b-41d4-a716-446655440000'
          end
          property :name do
            key :type, :string
          end
          property :capacity do
            key :type, :integer
          end
          property :location do
            key :type, :string
          end
        end

        schema :ReservationInput do
          key :type, :object
          key :required, %i[start_time end_time responsible]
          property :start_time do
            key :type, :string
            key :format, 'date-time'
            key :description, 'Data/hora de início (deve ser no futuro na criação)'
            key :example, '2026-07-01T10:00:00Z'
          end
          property :end_time do
            key :type, :string
            key :format, 'date-time'
            key :description, 'Data/hora de término (deve ser após start_time)'
            key :example, '2026-07-01T11:00:00Z'
          end
          property :description do
            key :type, :string
            key :description, 'Descrição opcional da reserva'
            key :example, 'Reunião de planejamento'
          end
          property :responsible do
            key :type, :string
            key :maxLength, 100
            key :description, 'Nome do responsável pela reserva'
            key :example, 'João Silva'
          end
          property :status do
            key :type, :string
            key :enum, %w[confirmed pending cancelled]
            key :description, 'Status da reserva'
            key :example, 'pending'
          end
        end

        schema :ReservationOutput do
          key :type, :object
          property :id do
            key :type, :string
            key :format, :uuid
          end
          property :room_id do
            key :type, :string
            key :format, :uuid
          end
          property :start_time do
            key :type, :string
            key :format, 'date-time'
          end
          property :end_time do
            key :type, :string
            key :format, 'date-time'
          end
          property :description do
            key :type, :string
            key :nullable, true
          end
          property :responsible do
            key :type, :string
          end
          property :status do
            key :type, :string
            key :enum, %w[confirmed pending cancelled]
          end
        end

        schema :LoginInput do
          key :type, :object
          key :required, %i[email password]
          property :email do
            key :type, :string
            key :format, :email
            key :example, 'admin@aeonflow.com'
          end
          property :password do
            key :type, :string
            key :format, :password
            key :example, 'admin123'
          end
        end

        schema :LoginOutput do
          key :type, :object
          property :token do
            key :type, :string
            key :description, 'JWT válido por 24 horas'
          end
          property :user do
            key :type, :object
            property :id do
              key :type, :string
              key :format, :uuid
            end
            property :email do
              key :type, :string
            end
            property :name do
              key :type, :string
            end
          end
        end
      end

      swagger_root do
        key :openapi, '3.0.0'
        info do
          key :version, '1.0.0'
          key :title, 'Aeon Flow — Meeting Room Reservation API'
          key :description, <<~DESC.strip
            API REST para gestão de salas de reunião e reservas.

            **Autenticação:** operações de escrita (POST, PUT, DELETE) exigem header `Authorization: Bearer <token>`.
            Obtenha o token via `POST /api/v1/auth/login`. Consultas GET de salas e reservas são públicas.

            **Regras de negócio:**
            - Uma sala não pode ter reservas sobrepostas (exceto canceladas).
            - Reservas devem ter data/hora no futuro (criação).
            - Cancelamento exige pelo menos 24 horas de antecedência.
          DESC
          contact do
            key :name, 'Lucas Alves da Silva'
            key :email, 'web4dev.lucas@outlook.com'
          end
          license do
            key :name, 'MIT'
          end
        end

        server do
          key :url, "http://localhost:#{ENV.fetch('PORT', 9292)}"
          key :description, 'Desenvolvimento local'
        end

        tag name: 'Auth', description: 'Autenticação JWT'
        tag name: 'Rooms', description: 'Gestão de salas de reunião'
        tag name: 'Reservations', description: 'Gestão de reservas por sala'
      end

      # ── Auth ──────────────────────────────────────────────────────────────────

      swagger_path '/api/v1/auth/login' do
        operation :post do
          key :summary, 'Autenticar usuário'
          key :description, 'Retorna um token JWT para uso nas rotas protegidas'
          key :operationId, 'login'
          key :tags, ['Auth']

          request_body do
            key :required, true
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/LoginInput' }
            end
          end

          response 200 do
            key :description, 'Login bem-sucedido'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/LoginOutput' }
            end
          end

          response 401 do
            key :description, 'Credenciais inválidas'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end
        end
      end

      # ── Rooms ───────────────────────────────────────────────────────────────

      swagger_path '/api/v1/rooms' do
        operation :get do
          key :summary, 'Listar salas'
          key :description, 'Retorna todas as salas. Suporta busca por nome via query param `search`.'
          key :operationId, 'listRooms'
          key :tags, ['Rooms']

          parameter name: :search, in: :query, type: :string, required: false,
                    description: 'Filtrar salas pelo nome (busca parcial)'

          response 200 do
            key :description, 'Lista de salas'
            content 'application/json' do
              schema do
                key :type, :array
                items { key :'$ref', '#/components/schemas/RoomOutput' }
              end
            end
          end
        end

        operation :post do
          key :summary, 'Criar sala'
          key :description, 'Cria uma nova sala de reunião'
          key :operationId, 'createRoom'
          key :tags, ['Rooms']

          security bearerAuth: []

          request_body do
            key :required, true
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/RoomInput' }
            end
          end

          response 201 do
            key :description, 'Sala criada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/RoomOutput' }
            end
          end

          response 401 do
            key :description, 'Não autenticado'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 422 do
            key :description, 'Erros de validação'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/ValidationErrors' }
            end
          end
        end
      end

      swagger_path '/api/v1/rooms/{id}' do
        operation :get do
          key :summary, 'Obter sala por ID'
          key :operationId, 'getRoom'
          key :tags, ['Rooms']

          parameter name: :id, in: :path, type: :string, required: true,
                    description: 'UUID da sala'

          response 200 do
            key :description, 'Detalhes da sala'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/RoomOutput' }
            end
          end

          response 404 do
            key :description, 'Sala não encontrada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end
        end

        operation :put do
          key :summary, 'Atualizar sala'
          key :operationId, 'updateRoom'
          key :tags, ['Rooms']

          security bearerAuth: []

          parameter name: :id, in: :path, type: :string, required: true

          request_body do
            key :required, true
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/RoomInput' }
            end
          end

          response 200 do
            key :description, 'Sala atualizada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/RoomOutput' }
            end
          end

          response 401 do
            key :description, 'Não autenticado'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 404 do
            key :description, 'Sala não encontrada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 422 do
            key :description, 'Erros de validação'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/ValidationErrors' }
            end
          end
        end

        operation :delete do
          key :summary, 'Excluir sala'
          key :description, 'Remove a sala e todas as reservas associadas (cascade)'
          key :operationId, 'deleteRoom'
          key :tags, ['Rooms']

          security bearerAuth: []

          parameter name: :id, in: :path, type: :string, required: true

          response 204 do
            key :description, 'Sala excluída'
          end

          response 401 do
            key :description, 'Não autenticado'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 404 do
            key :description, 'Sala não encontrada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end
        end
      end

      # ── Reservations ────────────────────────────────────────────────────────

      swagger_path '/api/v1/reservations' do
        operation :get do
          key :summary, 'Listar todas as reservas'
          key :description, 'Retorna reservas de todas as salas. Use os filtros opcionais para refinar a busca.'
          key :operationId, 'listAllReservations'
          key :tags, ['Reservations']

          parameter name: :status, in: :query, type: :string, required: false,
                    description: 'Filtrar por status', enum: %w[confirmed pending cancelled]
          parameter name: :start_time, in: :query, type: :string, required: false,
                    description: 'Filtrar reservas com início a partir desta data (ISO 8601)'
          parameter name: :end_time, in: :query, type: :string, required: false,
                    description: 'Filtrar reservas com término até esta data (ISO 8601)'
          parameter name: :search, in: :query, type: :string, required: false,
                    description: 'Buscar pelo nome do responsável'

          response 200 do
            key :description, 'Lista de reservas'
            content 'application/json' do
              schema do
                key :type, :array
                items { key :'$ref', '#/components/schemas/ReservationOutput' }
              end
            end
          end
        end
      end

      swagger_path '/api/v1/rooms/{room_id}/reservations' do
        operation :get do
          key :summary, 'Listar reservas de uma sala'
          key :description, 'Retorna as reservas de uma sala específica. Informe o UUID da sala (copie de GET /api/v1/rooms).'
          key :operationId, 'listReservations'
          key :tags, ['Reservations']

          parameter name: :room_id, in: :path, type: :string, required: true,
                    description: 'UUID da sala (obtenha via GET /api/v1/rooms)',
                    example: '41aa4c60-50e7-013f-fdf2-00155de0420b'
          parameter name: :status, in: :query, type: :string, required: false,
                    description: 'Filtrar por status', enum: %w[confirmed pending cancelled]
          parameter name: :start_time, in: :query, type: :string, required: false,
                    description: 'Filtrar reservas com início a partir desta data (ISO 8601)'
          parameter name: :end_time, in: :query, type: :string, required: false,
                    description: 'Filtrar reservas com término até esta data (ISO 8601)'
          parameter name: :search, in: :query, type: :string, required: false,
                    description: 'Buscar pelo nome do responsável'

          response 200 do
            key :description, 'Lista de reservas'
            content 'application/json' do
              schema do
                key :type, :array
                items { key :'$ref', '#/components/schemas/ReservationOutput' }
              end
            end
          end
        end

        operation :post do
          key :summary, 'Criar reserva'
          key :description, 'Cria uma reserva para a sala. Falha com 409 se houver conflito de horário.'
          key :operationId, 'createReservation'
          key :tags, ['Reservations']

          security bearerAuth: []

          parameter name: :room_id, in: :path, type: :string, required: true

          request_body do
            key :required, true
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/ReservationInput' }
            end
          end

          response 201 do
            key :description, 'Reserva criada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/ReservationOutput' }
            end
          end

          response 401 do
            key :description, 'Não autenticado'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 404 do
            key :description, 'Sala não encontrada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 409 do
            key :description, 'Sala indisponível no horário solicitado'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 422 do
            key :description, 'Erros de validação'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/ValidationErrors' }
            end
          end
        end
      end

      swagger_path '/api/v1/rooms/{room_id}/reservations/{id}' do
        operation :get do
          key :summary, 'Obter reserva por ID'
          key :description, <<~DESC.strip
            Retorna uma reserva específica. Copie o `id` de `GET /api/v1/reservations`
            ou da resposta do `POST` que criou a reserva. Não use o texto "id" — informe o UUID real.
          DESC
          key :operationId, 'getReservation'
          key :tags, ['Reservations']

          parameter name: :room_id, in: :path, type: :string, required: true,
                    description: 'UUID da sala',
                    example: 'c68db2ba-0463-49ba-b3fd-8965a4f0e616'
          parameter name: :id, in: :path, type: :string, required: true,
                    description: 'UUID da reserva (copie de GET /api/v1/reservations)',
                    example: '8f2920e0-50e9-013f-ffc4-00155de0420b'

          response 200 do
            key :description, 'Detalhes da reserva'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/ReservationOutput' }
            end
          end

          response 404 do
            key :description, 'Reserva não encontrada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end
        end

        operation :put do
          key :summary, 'Atualizar reserva'
          key :operationId, 'updateReservation'
          key :tags, ['Reservations']

          security bearerAuth: []

          parameter name: :room_id, in: :path, type: :string, required: true
          parameter name: :id, in: :path, type: :string, required: true

          request_body do
            key :required, true
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/ReservationInput' }
            end
          end

          response 200 do
            key :description, 'Reserva atualizada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/ReservationOutput' }
            end
          end

          response 401 do
            key :description, 'Não autenticado'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 404 do
            key :description, 'Reserva não encontrada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 409 do
            key :description, 'Conflito de horário'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 422 do
            key :description, 'Erros de validação'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/ValidationErrors' }
            end
          end
        end

        operation :delete do
          key :summary, 'Cancelar reserva'
          key :description, 'Cancela a reserva (status → cancelled). Exige 24h de antecedência.'
          key :operationId, 'cancelReservation'
          key :tags, ['Reservations']

          security bearerAuth: []

          parameter name: :room_id, in: :path, type: :string, required: true
          parameter name: :id, in: :path, type: :string, required: true

          response 204 do
            key :description, 'Reserva cancelada'
          end

          response 401 do
            key :description, 'Não autenticado'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 404 do
            key :description, 'Reserva não encontrada'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end

          response 422 do
            key :description, 'Cancelamento não permitido (menos de 24h de antecedência)'
            content 'application/json' do
              schema { key :'$ref', '#/components/schemas/Error' }
            end
          end
        end
      end
    end
  end
end
