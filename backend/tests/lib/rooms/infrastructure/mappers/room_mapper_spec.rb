# frozen_string_literal: true

require_relative '../../../../../src/lib/rooms/infrastructure/mappers/room_mapper'
require_relative '../../../../../src/lib/rooms/domain/entities/room_entity'

RSpec.describe Rooms::Infrastructure::Mappers::RoomMapper do
  let(:room) { Rooms::Domain::Entities::Room.new(name: 'Alpha', capacity: 10, location: 'Floor 1') }

  describe '.to_entity' do
    it 'maps a DAO hash to a room entity' do
      dao = {
        id: room.id.value,
        name: 'Alpha',
        capacity: 10,
        location: 'Floor 1'
      }

      entity = described_class.to_entity(dao)

      expect(entity.name).to eq('Alpha')
      expect(entity.id.value).to eq(room.id.value)
    end
  end

  describe '.to_dao' do
    it 'maps a room entity to a DAO hash' do
      dao = described_class.to_dao(room)

      expect(dao[:name]).to eq('Alpha')
      expect(dao[:capacity]).to eq(10)
      expect(dao[:location]).to eq('Floor 1')
    end
  end
end
