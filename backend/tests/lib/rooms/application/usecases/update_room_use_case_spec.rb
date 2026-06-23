# frozen_string_literal: true

require_relative '../../../../../src/lib/rooms/app_container'
require_relative '../../../../../src/lib/rooms/application/use_cases/update_room_use_case'
require_relative '../../../../../src/lib/rooms/application/repositories/room_repository'
require_relative '../../../../../src/lib/rooms/domain/entities/room_entity'
require_relative '../../../../../src/lib/shared_domain/infrastructure/unit_of_work'

RSpec.describe Rooms::Application::UseCases::UpdateRoomUseCase do
  let(:room_repository) { instance_double(Rooms::Application::Repositories::RoomRepository) }
  let(:unit_of_work) { instance_double(SharedDomain::Infrastructure::UnitOfWork) }
  let(:use_case) { described_class.new }

  before do
    allow(Rooms::AppContainer).to receive(:resolve).with('rooms.infrastructure.room_repository').and_return(room_repository)
    allow(Rooms::AppContainer).to receive(:resolve).with('infrastructure.unit_of_work').and_return(unit_of_work)
    allow(unit_of_work).to receive(:transaction).and_yield
  end

  describe '#call' do
    it 'updates an existing room' do
      room = Rooms::Domain::Entities::Room.new(name: 'Old', capacity: 5, location: 'A')
      allow(room_repository).to receive(:find_by_id).with(room.id.value).and_return(room)
      allow(room_repository).to receive(:update)

      result = use_case.call(id: room.id.value, name: 'New', capacity: 20, location: 'B')

      expect(result).to be_success
      expect(result.value!.name).to eq('New')
      expect(result.value!.capacity).to eq(20)
    end

    it 'returns not found when room does not exist' do
      allow(room_repository).to receive(:find_by_id).with('missing').and_return(nil)

      result = use_case.call(id: 'missing', name: 'X', capacity: 1, location: 'Y')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:not_found)
    end

    it 'returns validation error for invalid data' do
      room = Rooms::Domain::Entities::Room.new(name: 'Old', capacity: 5, location: 'A')
      allow(room_repository).to receive(:find_by_id).with(room.id.value).and_return(room)

      result = use_case.call(id: room.id.value, name: '', capacity: 10, location: 'A')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:unprocessable_entity)
    end
  end
end
