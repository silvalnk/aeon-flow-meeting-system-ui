# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../../lib/reservations/application/use_cases/cancel_reservation_use_case'

module App
  module Actions
    class CancelReservationAction < SharedDomain::Web::Action
      def call(params = {})
        Reservations::Application::UseCases::CancelReservationUseCase.new.call(
          room_id: params[:room_id],
          id: params[:id]
        ) do |m|
          m.success do |_|
            { status: 204, body: nil }
          end
          m.failure do |failure|
            case failure[:status]
            when :not_found then { status: 404, body: { error: failure[:message] } }
            when :unprocessable_entity then { status: 422, body: { error: failure[:message] } }
            else { status: 500, body: { error: failure[:message] } }
            end
          end
        end
      end
    end
  end
end
