# frozen_string_literal: true

require 'dry/monads'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require_relative '../../app_container'
require_relative '../../../shared_domain/application/use_case'

module Reservations
  module Application
    module UseCases
      class GetReservationUseCase < SharedDomain::Application::UseCase
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        def initialize
          @reservation_repository = Reservations::AppContainer.resolve('reservations.infrastructure.reservation_repository')
          super
        end

        def call(input_dto = {})
          reservation = @reservation_repository.find_by_id(input_dto[:room_id], input_dto[:id])
          return Failure(status: :not_found, message: 'Reservation not found') unless reservation

          Success(reservation)
        rescue StandardError => e
          Failure(status: :internal_server_error, message: e.message)
        end
      end
    end
  end
end
