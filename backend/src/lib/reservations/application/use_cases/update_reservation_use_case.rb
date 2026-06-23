# frozen_string_literal: true

require 'dry/monads'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require_relative '../../app_container'
require_relative '../../../shared_domain/application/use_case'
require_relative '../../domain/entities/reservation_entity'
require_relative '../../domain/errors/reservation_validation_error'

module Reservations
  module Application
    module UseCases
      class UpdateReservationUseCase < SharedDomain::Application::UseCase
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        def initialize
          @reservation_repository = Reservations::AppContainer.resolve('reservations.infrastructure.reservation_repository')
          @unit_of_work = Reservations::AppContainer.resolve('infrastructure.unit_of_work')
          super
        end

        def call(input_dto = {})
          @unit_of_work.transaction do
            existing = @reservation_repository.find_by_id(input_dto[:room_id], input_dto[:id])
            return Failure(status: :not_found, message: 'Reservation not found') unless existing
            return Failure(status: :unprocessable_entity, message: 'Cannot update a cancelled reservation') if existing.cancelled?

            reservation = Domain::Entities::Reservation.new(
              id: input_dto[:id],
              room_id: input_dto[:room_id],
              start_time: input_dto[:start_time] || existing.start_time,
              end_time: input_dto[:end_time] || existing.end_time,
              description: input_dto.key?(:description) ? input_dto[:description] : existing.description,
              responsible: input_dto[:responsible] || existing.responsible,
              status: input_dto[:status] || existing.status
            )

            if @reservation_repository.has_overlapping?(
              reservation.room_id,
              reservation.start_time,
              reservation.end_time,
              exclude_id: reservation.id.value
            )
              raise Domain::Errors::RoomNotAvailableError
            end

            @reservation_repository.update(reservation)
            Success(reservation)
          end
        rescue Reservations::Domain::Errors::ReservationValidationError => e
          Failure(status: :unprocessable_entity, errors: e.notification.errors, message: e.notification.error_messages.join(', '))
        rescue Reservations::Domain::Errors::RoomNotAvailableError => e
          Failure(status: :conflict, message: e.message)
        rescue StandardError => e
          Failure(status: :internal_server_error, message: e.message)
        end
      end
    end
  end
end
