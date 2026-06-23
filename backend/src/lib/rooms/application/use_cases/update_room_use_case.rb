# frozen_string_literal: true

require 'dry/monads'
require 'dry/matcher'
require 'dry/matcher/result_matcher'

require_relative '../../app_container'
require_relative '../../../shared_domain/application/use_case'
require_relative '../../domain/entities/room_entity'
require_relative '../../domain/errors/room_validation_error'

module Rooms
  module Application
    module UseCases
      class UpdateRoomUseCase < SharedDomain::Application::UseCase
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

        def initialize
          @room_repository = Rooms::AppContainer.resolve('rooms.infrastructure.room_repository')
          @unit_of_work = Rooms::AppContainer.resolve('infrastructure.unit_of_work')
          super
        end

        def call(input_dto = {})
          existing = @room_repository.find_by_id(input_dto[:id])
          return Failure(status: :not_found, message: 'Room not found') unless existing

          room = Domain::Entities::Room.new(
            id: input_dto[:id],
            name: input_dto[:name],
            capacity: input_dto[:capacity],
            location: input_dto[:location]
          )

          @unit_of_work.transaction do
            @room_repository.update(room)
            Success(room)
          end
        rescue Rooms::Domain::Errors::RoomValidationError => e
          Failure(
            status: :unprocessable_entity,
            errors: e.notification.errors,
            message: e.notification.error_messages.join(', ').to_s
          )
        rescue StandardError => e
          Failure(status: :internal_server_error, message: e.message)
        end
      end
    end
  end
end
