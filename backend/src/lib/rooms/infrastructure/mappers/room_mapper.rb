# frozen_string_literal: true

require_relative '../../../shared_domain/infrastructure/mapper'
require_relative '../../domain/entities/room_entity'
require_relative '../../../shared_domain/domain/value_objects/uuid_value_object'

module Rooms
  module Infrastructure
    module Mappers
      class RoomMapper < SharedDomain::Infrastructure::Mapper
        def self.to_entity(dao)
          Domain::Entities::Room.new(
            id: dao[:id].to_s,
            name: dao[:name],
            capacity: dao[:capacity],
            location: dao[:location]
          )
        end

        def self.to_dao(entity)
          {
            id: entity.id,
            name: entity.name,
            capacity: entity.capacity,
            location: entity.location
          }
        end
      end
    end
  end
end
