# frozen_string_literal: true

require_relative '../../../shared_domain/domain/notification'

module Reservations
  module Domain
    module Errors
      class ReservationValidationError < StandardError
        attr_reader :notification

        def initialize(notification)
          @notification = notification
          super(notification.error_messages.join(', '))
        end
      end

      class RoomNotAvailableError < StandardError
        def initialize
          super('Room is not available for the requested time slot')
        end
      end

      class CancellationNotAllowedError < StandardError
        def initialize
          super('Reservations can only be cancelled at least 24 hours in advance')
        end
      end
    end
  end
end
