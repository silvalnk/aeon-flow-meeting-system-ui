# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../../lib/rooms/application/use_cases/delete_room_use_case'

module App
  module Actions
    class DeleteRoomAction < SharedDomain::Web::Action
      def call(params = {})
        Rooms::Application::UseCases::DeleteRoomUseCase.new.call(id: params[:id]) do |m|
          m.success do |_|
            { status: 204, body: nil }
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
