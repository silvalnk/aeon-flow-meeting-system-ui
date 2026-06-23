# frozen_string_literal: true

require_relative '../../../src/app/serializers/room_serializer'
require_relative '../../../src/lib/rooms/domain/entities/room_entity'

RSpec.describe App::Serializers::RoomSerializer do
  let(:room) { Rooms::Domain::Entities::Room.new(name: 'Alpha', capacity: 10, location: 'Floor 1') }

  describe '.serialize' do
    it 'serializes a room entity' do
      result = described_class.serialize(room)

      expect(result).to eq(
        id: room.id.value,
        name: 'Alpha',
        capacity: 10,
        location: 'Floor 1'
      )
    end
  end

  describe '.serialize_collection' do
    it 'serializes a collection of rooms' do
      room2 = Rooms::Domain::Entities::Room.new(name: 'Beta', capacity: 20, location: 'Floor 2')

      result = described_class.serialize_collection([room, room2])

      expect(result.length).to eq(2)
      expect(result.map { |r| r[:name] }).to contain_exactly('Alpha', 'Beta')
    end
  end
end
