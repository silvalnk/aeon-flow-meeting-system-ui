# frozen_string_literal: true

require_relative '../../app_container'
require_relative '../../application/repositories/room_repository'
require_relative '../mappers/room_mapper'

module Rooms
  module Infrastructure
    module Repositories
      class SqliteRoomRepository < Rooms::Application::Repositories::RoomRepository
        def initialize
          @rom = Rooms::AppContainer.resolve('infrastructure.rom')
          super
        end

        def add(entity)
          @rom[:rooms].command(:create).call(
            id: entity.id.value,
            name: entity.name,
            capacity: entity.capacity,
            location: entity.location
          )
        end

        def find_all(filters = {})
          relation = @rom[:rooms]
          relation = relation.where(Sequel.like(:name, "%#{filters[:search]}%")) if filters[:search]

          relation.to_a.map { |room| to_entity(room) }
        end

        def find_by_id(id)
          room = @rom[:rooms].by_pk(id).one
          return nil unless room

          to_entity(room)
        end

        def update(entity)
          @rom[:rooms].by_pk(entity.id.value).command(:update).call(
            name: entity.name,
            capacity: entity.capacity,
            location: entity.location
          )
        end

        def delete(id)
          @rom[:rooms].by_pk(id).command(:delete).call
        end

        private

        def to_entity(dao)
          Mappers::RoomMapper.to_entity(dao)
        end
      end
    end
  end
end
