# frozen_string_literal: true

require_relative 'reservation_validation'
require_relative '../../../shared_domain/domain/notification'

module Reservations
  module Domain
    module Validations
      module ReservationValidationService
        module_function

        def evaluate_attributes(attributes, for_update: false)
          result = ReservationValidation.new.call(attributes)
          notification = to_notification(result)
          unless for_update || notification.has_errors?
            begin
              start_time = attributes[:start_time].is_a?(DateTime) ? attributes[:start_time] : DateTime.parse(attributes[:start_time].to_s)
              notification.add_error(:start_time, 'must be in the future') if start_time <= DateTime.now
            rescue ArgumentError
              notification.add_error(:start_time, 'must be a valid datetime')
            end
          end
          notification
        end

        def to_notification(result)
          notification = SharedDomain::Domain::Notification.new
          if result.failure?
            result.errors.to_h.each do |field, messages|
              messages.each { |message| notification.add_error(field, message.to_s) }
            end
          end
          notification
        end
        private_class_method :to_notification
      end
    end
  end
end
