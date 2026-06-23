# frozen_string_literal: true

require_relative '../../../../../src/lib/rooms/app_container'
require_relative '../../../../../src/lib/rooms/application/use_cases/list_rooms_use_case'
require_relative '../../../../../src/lib/rooms/application/repositories/room_repository'

RSpec.describe Rooms::Application::UseCases::ListRoomsUseCase do
  let(:room_repository) { instance_double(Rooms::Application::Repositories::RoomRepository) }
  let(:use_case) { described_class.new }

  before do
    allow(Rooms::AppContainer).to receive(:resolve).with('rooms.infrastructure.room_repository').and_return(room_repository)
  end

  describe '#call' do
    it 'returns all rooms' do
      rooms = [instance_double(Rooms::Domain::Entities::Room)]
      allow(room_repository).to receive(:find_all).with({}).and_return(rooms)

      result = use_case.call

      expect(result).to be_success
      expect(result.value!).to eq(rooms)
    end

    it 'passes search filter to repository' do
      allow(room_repository).to receive(:find_all).with({ search: 'Alpha' }).and_return([])

      result = use_case.call(search: 'Alpha')

      expect(result).to be_success
    end
  end
end
