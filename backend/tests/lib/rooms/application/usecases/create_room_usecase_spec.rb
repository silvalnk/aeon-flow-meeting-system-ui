# frozen_string_literal: true

require_relative '../../../../../src/lib/rooms/app_container'
require_relative '../../../../../src/lib/rooms/application/use_cases/create_room_use_case'
require_relative '../../../../../src/lib/rooms/domain/entities/room_entity'
require_relative '../../../../../src/lib/rooms/application/repositories/room_repository'
require_relative '../../../../../src/lib/shared_domain/infrastructure/unit_of_work'

RSpec.describe Rooms::Application::UseCases::CreateRoomUseCase do
  let(:room_repository) { instance_double(Rooms::Application::Repositories::RoomRepository) }
  let(:unit_of_work) { instance_double(SharedDomain::Infrastructure::UnitOfWork) }
  let(:use_case) { described_class.new }

  before do
    allow(Rooms::AppContainer).to receive(:resolve).with('rooms.infrastructure.room_repository').and_return(room_repository)
    allow(Rooms::AppContainer).to receive(:resolve).with('infrastructure.unit_of_work').and_return(unit_of_work)
  end

  describe '#call' do
    context 'with valid input data' do
      before do
        allow(unit_of_work).to receive(:transaction).and_yield
        allow(room_repository).to receive(:add).with(instance_of(Rooms::Domain::Entities::Room))
      end

      it 'creates a new room successfully' do
        sut = use_case.call({
          name: 'Conference',
          capacity: 10,
          location: 'Room 4'
        })

        expect(sut).to be_success
        expect(sut.value!.name).to eq('Conference')
        expect(sut.value!.capacity).to eq(10)
        expect(sut.value!.location).to eq('Room 4')
      end
    end

    context 'with invalid input data' do
      before do
        allow(unit_of_work).to receive(:transaction).and_yield
      end

      it 'returns validation failure' do
        result = use_case.call(name: '', capacity: 10, location: 'Room 4')

        expect(result).to be_failure
        expect(result.failure[:status]).to eq(:unprocessable_entity)
      end
    end
  end
end
