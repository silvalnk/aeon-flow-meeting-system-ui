# frozen_string_literal: true

require_relative '../../lib/shared_domain/web/action'
require_relative '../../lib/reservations/application/use_cases/list_reservations_use_case'
require_relative '../serializers/reservation_serializer'

module App
  module Actions
    class ListReservationsAction < SharedDomain::Web::Action
      def call(params = {})
        Reservations::Application::UseCases::ListReservationsUseCase.new.call(
          room_id: params[:room_id],
          status: params[:status],
          start_time: params[:start_time],
          end_time: params[:end_time],
          search: params[:search]
        ) do |m|
          m.success do |reservations|
            { status: 200, body: App::Serializers::ReservationSerializer.serialize_collection(reservations) }
          end
          m.failure do |failure|
            { status: 500, body: { error: failure[:message] } }
          end
        end
      end
    end
  end
end
