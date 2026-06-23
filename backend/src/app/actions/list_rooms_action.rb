# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../../lib/rooms/application/use_cases/list_rooms_use_case'
require_relative '../serializers/room_serializer'

module App
  module Actions
    class ListRoomsAction < SharedDomain::Web::Action
      def call(params = {})
        Rooms::Application::UseCases::ListRoomsUseCase.new.call(search: params[:search]) do |m|
          m.success do |rooms|
            { status: 200, body: App::Serializers::RoomSerializer.serialize_collection(rooms) }
          end
          m.failure do |failure|
            { status: 500, body: { error: failure[:message] } }
          end
        end
      end
    end
  end
end
