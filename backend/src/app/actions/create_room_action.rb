# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../serializers/room_serializer'
require_relative '../../lib/rooms/application/use_cases/create_room_use_case'

module App
  module Actions
    class CreateRoomAction < SharedDomain::Web::Action
      def call(params = {})
        input_dto = {
          name: params[:name],
          capacity: params[:capacity],
          location: params[:location]
        }

        Rooms::Application::UseCases::CreateRoomUseCase.new.call(input_dto) do |m|
          m.success do |room|
            {
              status: 201,
              body: App::Serializers::RoomSerializer.serialize(room)
            }
          end

          m.failure do |failure|
            case failure[:status]
            when :unprocessable_entity
              {
                status: 422,
                body: { errors: failure[:errors] }
              }
            else
              {
                status: 500,
                body: { error: failure[:message] }
              }
            end
          end
        end
      end
    end
  end
end
