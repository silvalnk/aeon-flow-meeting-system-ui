# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../../lib/rooms/application/use_cases/get_room_use_case'
require_relative '../serializers/room_serializer'

module App
  module Actions
    class GetRoomAction < SharedDomain::Web::Action
      def call(params = {})
        Rooms::Application::UseCases::GetRoomUseCase.new.call(id: params[:id]) do |m|
          m.success do |room|
            { status: 200, body: App::Serializers::RoomSerializer.serialize(room) }
          end
          m.failure do |failure|
            case failure[:status]
            when :not_found then { status: 404, body: { error: failure[:message] } }
            else { status: 500, body: { error: failure[:message] } }
            end
          end
        end
      end
    end
  end
end
