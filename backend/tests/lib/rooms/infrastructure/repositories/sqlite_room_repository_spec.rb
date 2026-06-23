# frozen_string_literal: true

require_relative '../../../../../src/lib/rooms/infrastructure/repositories/sqlite_room_repository'
require_relative '../../../../../src/lib/shared_domain/infrastructure/rom'
require_relative '../../../../../src/lib/rooms/domain/entities/room_entity'
require_relative '../../../../support/database_helper'

RSpec.describe Rooms::Infrastructure::Repositories::SqliteRoomRepository do
  let(:rom) { DatabaseHelper.rom }
  let(:repository) { described_class.new }

  before do
    DatabaseHelper.truncate_all!
    allow(Rooms::AppContainer).to receive(:resolve).with('infrastructure.rom').and_return(rom)
  end

  after do
    rom.container.disconnect
  end

  describe '#add' do
    it 'persists a new room' do
      room = Rooms::Domain::Entities::Room.new(
        name: 'Conference',
        capacity: 10,
        location: 'Room 4'
      )

      expect {
        repository.add(room)
      }.to change { rom[:rooms].count }.by(1)
    end
  end

  describe '#find_all' do
    it 'returns all rooms' do
      room = Rooms::Domain::Entities::Room.new(name: 'Alpha', capacity: 5, location: 'A')
      repository.add(room)

      expect(repository.find_all.size).to eq(1)
    end

    it 'filters by search term' do
      repository.add(Rooms::Domain::Entities::Room.new(name: 'Alpha', capacity: 5, location: 'A'))
      repository.add(Rooms::Domain::Entities::Room.new(name: 'Beta', capacity: 5, location: 'B'))

      results = repository.find_all(search: 'Alpha')

      expect(results.size).to eq(1)
      expect(results.first.name).to eq('Alpha')
    end
  end

  describe '#find_by_id' do
    it 'returns the room when it exists' do
      room = Rooms::Domain::Entities::Room.new(name: 'Alpha', capacity: 5, location: 'A')
      repository.add(room)

      found = repository.find_by_id(room.id.value)

      expect(found.name).to eq('Alpha')
    end

    it 'returns nil when room does not exist' do
      expect(repository.find_by_id('missing')).to be_nil
    end
  end

  describe '#update' do
    it 'updates room attributes' do
      room = Rooms::Domain::Entities::Room.new(name: 'Old', capacity: 5, location: 'A')
      repository.add(room)

      updated = Rooms::Domain::Entities::Room.new(
        id: room.id.value,
        name: 'New',
        capacity: 20,
        location: 'B'
      )
      repository.update(updated)

      found = repository.find_by_id(room.id.value)
      expect(found.name).to eq('New')
      expect(found.capacity).to eq(20)
    end
  end

  describe '#delete' do
    it 'removes the room' do
      room = Rooms::Domain::Entities::Room.new(name: 'Alpha', capacity: 5, location: 'A')
      repository.add(room)

      expect {
        repository.delete(room.id.value)
      }.to change { rom[:rooms].count }.by(-1)
    end
  end
end
