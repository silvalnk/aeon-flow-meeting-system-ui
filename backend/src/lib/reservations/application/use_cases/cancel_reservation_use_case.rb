# frozen_string_literal: true

require 'dry/monads'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require_relative '../../app_container'
require_relative '../../../shared_domain/application/use_case'
require_relative '../../domain/errors/reservation_validation_error'

module Reservations
  module Application
    module UseCases
      class CancelReservationUseCase < SharedDomain::Application::UseCase
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        CANCELLATION_WINDOW_HOURS = 24

        def initialize
          @reservation_repository = Reservations::AppContainer.resolve('reservations.infrastructure.reservation_repository')
          @unit_of_work = Reservations::AppContainer.resolve('infrastructure.unit_of_work')
          super
        end

        def call(input_dto = {})
          existing = @reservation_repository.find_by_id(input_dto[:room_id], input_dto[:id])
          return Failure(status: :not_found, message: 'Reservation not found') unless existing
          return Failure(status: :unprocessable_entity, message: 'Reservation is already cancelled') if existing.cancelled?

          hours_until_start = ((existing.start_time - DateTime.now) * 24).to_f
          if hours_until_start < CANCELLATION_WINDOW_HOURS
            return Failure(status: :unprocessable_entity, message: Domain::Errors::CancellationNotAllowedError.new.message)
          end

          cancelled = Domain::Entities::Reservation.new(
            id: existing.id.value,
            room_id: existing.room_id,
            start_time: existing.start_time,
            end_time: existing.end_time,
            description: existing.description,
            responsible: existing.responsible,
            status: 'cancelled',
            persisted: true
          )

          @unit_of_work.transaction do
            @reservation_repository.update(cancelled)
            Success(nil)
          end
        rescue StandardError => e
          Failure(status: :internal_server_error, message: e.message)
        end
      end
    end
  end
end
