# frozen_string_literal: true

require_relative '../../../shared_domain/infrastructure/mapper'
require_relative '../../domain/entities/reservation_entity'
require_relative '../../../shared_domain/domain/value_objects/uuid_value_object'

module Reservations
  module Infrastructure
    module Mappers
      class ReservationMapper < SharedDomain::Infrastructure::Mapper
        def self.to_entity(dao)
          Domain::Entities::Reservation.new(
            id: dao[:id].to_s,
            room_id: dao[:room_id].to_s,
            start_time: coerce_datetime(dao[:start_time]),
            end_time: coerce_datetime(dao[:end_time]),
            description: dao[:description],
            responsible: dao[:responsible],
            status: dao[:status],
            persisted: true
          )
        end

        def self.coerce_datetime(value)
          return value if value.is_a?(DateTime)
          return value.to_datetime if value.is_a?(Time)

          DateTime.parse(value.to_s)
        end

        def self.to_dao(entity)
          {
            id: entity.id.value,
            room_id: entity.room_id,
            start_time: entity.start_time,
            end_time: entity.end_time,
            description: entity.description,
            responsible: entity.responsible,
            status: entity.status
          }
        end
      end
    end
  end
end
