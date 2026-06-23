# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../../lib/rooms/application/use_cases/update_room_use_case'
require_relative '../serializers/room_serializer'

module App
  module Actions
    class UpdateRoomAction < SharedDomain::Web::Action
      def call(params = {})
        input_dto = {
          id: params[:id],
          name: params[:name],
          capacity: params[:capacity],
          location: params[:location]
        }

        Rooms::Application::UseCases::UpdateRoomUseCase.new.call(input_dto) do |m|
          m.success do |room|
            { status: 200, body: App::Serializers::RoomSerializer.serialize(room) }
          end
          m.failure do |failure|
            case failure[:status]
            when :unprocessable_entity then { status: 422, body: { errors: failure[:errors] } }
            when :not_found then { status: 404, body: { error: failure[:message] } }
            else { status: 500, body: { error: failure[:message] } }
            end
          end
        end
      end
    end
  end
end
