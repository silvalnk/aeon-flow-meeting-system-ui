# frozen_string_literal: true

require 'dry/monads'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require_relative '../../app_container'
require_relative '../../../shared_domain/application/use_case'

module Rooms
  module Application
    module UseCases
      class GetRoomUseCase < SharedDomain::Application::UseCase
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        def initialize
          @room_repository = Rooms::AppContainer.resolve('rooms.infrastructure.room_repository')
          super
        end

        def call(input_dto = {})
          room = @room_repository.find_by_id(input_dto[:id])
          return Failure(status: :not_found, message: 'Room not found') unless room

          Success(room)
        rescue StandardError => e
          Failure(status: :internal_server_error, message: e.message)
        end
      end
    end
  end
end
