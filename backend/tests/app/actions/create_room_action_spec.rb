# frozen_string_literal: true

require_relative '../../../src/app/actions/create_room_action'
require_relative '../../../src/lib/rooms/app_container'
require_relative '../../../src/lib/rooms/application/repositories/room_repository'
require_relative '../../../src/lib/shared_domain/infrastructure/unit_of_work'

RSpec.describe App::Actions::CreateRoomAction do
  let(:action) { described_class.new }
  let(:room_repository) { instance_double(Rooms::Application::Repositories::RoomRepository) }
  let(:unit_of_work) { instance_double(SharedDomain::Infrastructure::UnitOfWork) }

  before do
    allow(Rooms::AppContainer).to receive(:resolve).with('rooms.infrastructure.room_repository').and_return(room_repository)
    allow(Rooms::AppContainer).to receive(:resolve).with('infrastructure.unit_of_work').and_return(unit_of_work)
    allow(unit_of_work).to receive(:transaction).and_yield
    allow(room_repository).to receive(:add)
  end

  describe '#call' do
    it 'returns 201 on success' do
      result = action.call(name: 'Alpha', capacity: 10, location: 'Floor 1')

      expect(result[:status]).to eq(201)
      expect(result[:body][:name]).to eq('Alpha')
      expect(result[:body][:id]).not_to be_nil
    end

    it 'returns 422 on validation error' do
      result = action.call(name: '', capacity: 10, location: 'Floor 1')

      expect(result[:status]).to eq(422)
      expect(result[:body]).to have_key(:errors)
    end
  end
end
