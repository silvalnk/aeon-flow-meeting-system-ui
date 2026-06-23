# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../../lib/reservations/application/use_cases/create_reservation_use_case'
require_relative '../serializers/reservation_serializer'

module App
  module Actions
    class CreateReservationAction < SharedDomain::Web::Action
      def call(params = {})
        input_dto = {
          room_id: params[:room_id],
          start_time: params[:start_time],
          end_time: params[:end_time],
          description: params[:description],
          responsible: params[:responsible],
          status: params[:status]
        }

        Reservations::Application::UseCases::CreateReservationUseCase.new.call(input_dto) do |m|
          m.success do |reservation|
            { status: 201, body: App::Serializers::ReservationSerializer.serialize(reservation) }
          end
          m.failure do |failure|
            case failure[:status]
            when :unprocessable_entity then { status: 422, body: { errors: failure[:errors] || failure[:message] } }
            when :not_found then { status: 404, body: { error: failure[:message] } }
            when :conflict then { status: 409, body: { error: failure[:message] } }
            else { status: 500, body: { error: failure[:message] } }
            end
          end
        end
      end
    end
  end
end
