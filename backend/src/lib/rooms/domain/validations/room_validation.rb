# frozen_string_literal: true

require_relative '../../../shared_domain/domain/validation'
require_relative '../../../shared_domain/domain/notification'

module Rooms
  module Domain
    module Validations
      class RoomValidation < SharedDomain::Domain::Validation
        params do
          required(:name).filled(:string, max_size?: 100)
          required(:capacity).filled(:integer, gt?: 0)
          required(:location).filled(:string)
        end

        def validate_attributes(attributes)
          result = call(attributes)
          notification = to_notification(result)
          unless notification.has_errors?
            begin
              attributes[:capacity] = Integer(attributes[:capacity])
            rescue ArgumentError, TypeError
              notification.add_error(:capacity, 'must be a valid integer')
            end
          end
          notification
        end

        private

        def to_notification(result)
          notification = SharedDomain::Domain::Notification.new
          if result.failure?
            result.errors.to_h.each do |field, messages|
              messages.each { |message| notification.add_error(field, message.to_s) }
            end
          end
          notification
        end
      end
    end
  end
end
