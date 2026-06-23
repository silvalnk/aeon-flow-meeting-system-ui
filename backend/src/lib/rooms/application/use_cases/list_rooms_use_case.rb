# frozen_string_literal: true

require 'dry/monads'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require_relative '../../app_container'
require_relative '../../../shared_domain/application/use_case'

module Rooms
  module Application
    module UseCases
      class ListRoomsUseCase < SharedDomain::Application::UseCase
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        def initialize
          @room_repository = Rooms::AppContainer.resolve('rooms.infrastructure.room_repository')
          super
        end

        def call(input_dto = {})
          filters = {}
          filters[:search] = input_dto[:search] if input_dto[:search]

          rooms = @room_repository.find_all(filters)
          Success(rooms)
        rescue StandardError => e
          Failure(status: :internal_server_error, message: e.message)
        end
      end
    end
  end
end
