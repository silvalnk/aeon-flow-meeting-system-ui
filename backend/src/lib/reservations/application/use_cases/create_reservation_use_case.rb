# frozen_string_literal: true

require 'dry/monads'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require_relative '../../app_container'
require_relative '../../../shared_domain/application/use_case'
require_relative '../../domain/entities/reservation_entity'
require_relative '../../domain/errors/reservation_validation_error'
require_relative '../../../rooms/app_container'

module Reservations
  module Application
    module UseCases
      class CreateReservationUseCase < SharedDomain::Application::UseCase
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        def initialize
          @reservation_repository = Reservations::AppContainer.resolve('reservations.infrastructure.reservation_repository')
          @room_repository = Rooms::AppContainer.resolve('rooms.infrastructure.room_repository')
          @unit_of_work = Reservations::AppContainer.resolve('infrastructure.unit_of_work')
          super
        end

        def call(input_dto = {})
          room = @room_repository.find_by_id(input_dto[:room_id])
          return Failure(status: :not_found, message: 'Room not found') unless room

          reservation = Domain::Entities::Reservation.new(
            room_id: input_dto[:room_id],
            start_time: input_dto[:start_time],
            end_time: input_dto[:end_time],
            description: input_dto[:description],
            responsible: input_dto[:responsible],
            status: input_dto[:status] || 'pending'
          )

          if @reservation_repository.has_overlapping?(
            reservation.room_id,
            reservation.start_time,
            reservation.end_time
          )
            return Failure(status: :conflict, message: Domain::Errors::RoomNotAvailableError.new.message)
          end

          @unit_of_work.transaction do
            @reservation_repository.add(reservation)
            Success(reservation)
          end
        rescue Reservations::Domain::Errors::ReservationValidationError => e
          Failure(status: :unprocessable_entity, errors: e.notification.errors, message: e.notification.error_messages.join(', '))
        rescue StandardError => e
          Failure(status: :internal_server_error, message: e.message)
        end
      end
    end
  end
end
