# frozen_string_literal: true

require_relative '../../../../../src/lib/rooms/app_container'
require_relative '../../../../../src/lib/rooms/application/use_cases/get_room_use_case'
require_relative '../../../../../src/lib/rooms/application/repositories/room_repository'
require_relative '../../../../../src/lib/rooms/domain/entities/room_entity'

RSpec.describe Rooms::Application::UseCases::GetRoomUseCase do
  let(:room_repository) { instance_double(Rooms::Application::Repositories::RoomRepository) }
  let(:use_case) { described_class.new }

  before do
    allow(Rooms::AppContainer).to receive(:resolve).with('rooms.infrastructure.room_repository').and_return(room_repository)
  end

  describe '#call' do
    it 'returns the room when found' do
      room = Rooms::Domain::Entities::Room.new(name: 'Alpha', capacity: 10, location: 'Floor 1')
      allow(room_repository).to receive(:find_by_id).with(room.id.value).and_return(room)

      result = use_case.call(id: room.id.value)

      expect(result).to be_success
      expect(result.value!).to eq(room)
    end

    it 'returns not found when room does not exist' do
      allow(room_repository).to receive(:find_by_id).with('missing').and_return(nil)

      result = use_case.call(id: 'missing')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:not_found)
    end
  end
end
