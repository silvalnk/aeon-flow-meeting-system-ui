# frozen_string_literal: true

require_relative '../../../shared_domain/domain/entity'
require_relative '../../../shared_domain/domain/value_objects/uuid_value_object'
require_relative '../errors/reservation_validation_error'
require_relative '../validations/reservation_validation_service'

module Reservations
  module Domain
    module Entities
      class Reservation < SharedDomain::Domain::Entity
        STATUSES = %w[confirmed pending cancelled].freeze

        attribute :room_id, SharedDomain::Domain::Types::Strict::String
        attribute :start_time, SharedDomain::Domain::Types::Strict::DateTime
        attribute :end_time, SharedDomain::Domain::Types::Strict::DateTime
        attribute :description, SharedDomain::Domain::Types::Strict::String.optional.default(nil)
        attribute :responsible, SharedDomain::Domain::Types::Strict::String
        attribute :status, SharedDomain::Domain::Types::Strict::String.default('pending'.freeze)

        extend(Module.new do
          def new(attributes)
            attributes = coerce_time_attributes(attributes.dup)

            unless attributes[:persisted]
              for_update = attributes[:id].is_a?(String) || attributes[:id].is_a?(SharedDomain::Domain::ValueObjects::UuidValueObject)
              validation = Reservations::Domain::Validations::ReservationValidationService.evaluate_attributes(attributes, for_update: for_update)
              raise Reservations::Domain::Errors::ReservationValidationError, validation if validation.has_errors?
            end

            attributes.delete(:persisted)
            super
          end

          def coerce_time_attributes(attributes)
            attributes[:start_time] = coerce_time(attributes[:start_time]) if attributes[:start_time]
            attributes[:end_time] = coerce_time(attributes[:end_time]) if attributes[:end_time]
            attributes
          end

          def coerce_time(value)
            return value if value.is_a?(DateTime)
            return value.to_datetime if value.is_a?(Time)

            DateTime.parse(value.to_s)
          end
        end)

        def initialize(attributes)
          attributes[:id] = if attributes[:id].is_a?(String)
                              SharedDomain::Domain::ValueObjects::UuidValueObject.new(value: attributes[:id])
                            else
                              SharedDomain::Domain::ValueObjects::UuidValueObject.new
                            end
          super
        end

        def cancelled?
          status == 'cancelled'
        end

        def confirmed?
          status == 'confirmed'
        end
      end
    end
  end
end
