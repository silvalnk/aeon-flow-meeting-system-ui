# frozen_string_literal: true

module App
  module Serializers
    module RoomSerializer
      module_function

      def serialize(room)
        {
          id: room.id.value,
          name: room.name,
          capacity: room.capacity,
          location: room.location
        }
      end

      def serialize_collection(rooms)
        rooms.map { |room| serialize(room) }
      end
    end
  end
end
