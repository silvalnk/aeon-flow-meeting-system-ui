# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../../lib/reservations/application/use_cases/get_reservation_use_case'
require_relative '../serializers/reservation_serializer'

module App
  module Actions
    class GetReservationAction < SharedDomain::Web::Action
      def call(params = {})
        Reservations::Application::UseCases::GetReservationUseCase.new.call(
          room_id: params[:room_id],
          id: params[:id]
        ) do |m|
          m.success do |reservation|
            { status: 200, body: App::Serializers::ReservationSerializer.serialize(reservation) }
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
