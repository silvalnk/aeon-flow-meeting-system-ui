# frozen_string_literal: true

require 'dry/monads'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require_relative '../../app_container'
require_relative '../../../shared_domain/application/use_case'

module Reservations
  module Application
    module UseCases
      class ListReservationsUseCase < SharedDomain::Application::UseCase
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        def initialize
          @reservation_repository = Reservations::AppContainer.resolve('reservations.infrastructure.reservation_repository')
          super
        end

        def call(input_dto = {})
          filters = {}
          filters[:status] = input_dto[:status] if present?(input_dto[:status])
          filters[:start_time] = DateTime.parse(input_dto[:start_time]) if present?(input_dto[:start_time])
          filters[:end_time] = DateTime.parse(input_dto[:end_time]) if present?(input_dto[:end_time])
          filters[:search] = input_dto[:search] if present?(input_dto[:search])

          room_id = input_dto[:room_id]
          room_id = nil unless present?(room_id)

          reservations = @reservation_repository.find_all(room_id, filters)
          Success(reservations)
        rescue ArgumentError => e
          Failure(status: :unprocessable_entity, message: e.message)
        rescue StandardError => e
          Failure(status: :internal_server_error, message: e.message)
        end

        private

        def present?(value)
          !value.nil? && value.to_s.strip != ''
        end
      end
    end
  end
end
