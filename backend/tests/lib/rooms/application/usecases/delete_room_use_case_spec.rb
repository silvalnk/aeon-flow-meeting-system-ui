# frozen_string_literal: true

require_relative '../../../../../src/lib/rooms/app_container'
require_relative '../../../../../src/lib/rooms/application/use_cases/delete_room_use_case'
require_relative '../../../../../src/lib/rooms/application/repositories/room_repository'
require_relative '../../../../../src/lib/rooms/domain/entities/room_entity'
require_relative '../../../../../src/lib/shared_domain/infrastructure/unit_of_work'

RSpec.describe Rooms::Application::UseCases::DeleteRoomUseCase do
  let(:room_repository) { instance_double(Rooms::Application::Repositories::RoomRepository) }
  let(:unit_of_work) { instance_double(SharedDomain::Infrastructure::UnitOfWork) }
  let(:use_case) { described_class.new }

  before do
    allow(Rooms::AppContainer).to receive(:resolve).with('rooms.infrastructure.room_repository').and_return(room_repository)
    allow(Rooms::AppContainer).to receive(:resolve).with('infrastructure.unit_of_work').and_return(unit_of_work)
    allow(unit_of_work).to receive(:transaction).and_yield
  end

  describe '#call' do
    it 'deletes an existing room' do
      room = Rooms::Domain::Entities::Room.new(name: 'Alpha', capacity: 10, location: 'A')
      allow(room_repository).to receive(:find_by_id).with(room.id.value).and_return(room)
      allow(room_repository).to receive(:delete).with(room.id.value)

      result = use_case.call(id: room.id.value)

      expect(result).to be_success
    end

    it 'returns not found when room does not exist' do
      allow(room_repository).to receive(:find_by_id).with('missing').and_return(nil)

      result = use_case.call(id: 'missing')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:not_found)
    end
  end
end
