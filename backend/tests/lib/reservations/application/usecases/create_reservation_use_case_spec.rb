# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/app_container'
require_relative '../../../../../src/lib/reservations/application/use_cases/create_reservation_use_case'
require_relative '../../../../../src/lib/reservations/application/repositories/reservation_repository'
require_relative '../../../../../src/lib/rooms/application/repositories/room_repository'
require_relative '../../../../../src/lib/rooms/domain/entities/room_entity'
require_relative '../../../../../src/lib/shared_domain/infrastructure/unit_of_work'

RSpec.describe Reservations::Application::UseCases::CreateReservationUseCase do
  let(:reservation_repository) { instance_double(Reservations::Application::Repositories::ReservationRepository) }
  let(:room_repository) { instance_double(Rooms::Application::Repositories::RoomRepository) }
  let(:unit_of_work) { instance_double(SharedDomain::Infrastructure::UnitOfWork) }
  let(:use_case) { described_class.new }
  let(:room) { Rooms::Domain::Entities::Room.new(name: 'Alpha', capacity: 10, location: 'A') }
  let(:start_time) { future_datetime(2) }
  let(:end_time) { start_time + Rational(1, 24) }

  before do
    allow(Reservations::AppContainer).to receive(:resolve).with('reservations.infrastructure.reservation_repository').and_return(reservation_repository)
    allow(Rooms::AppContainer).to receive(:resolve).with('rooms.infrastructure.room_repository').and_return(room_repository)
    allow(Reservations::AppContainer).to receive(:resolve).with('infrastructure.unit_of_work').and_return(unit_of_work)
    allow(unit_of_work).to receive(:transaction).and_yield
  end

  describe '#call' do
    it 'creates a reservation successfully' do
      allow(room_repository).to receive(:find_by_id).with(room.id.value).and_return(room)
      allow(reservation_repository).to receive(:has_overlapping?).and_return(false)
      allow(reservation_repository).to receive(:add)

      result = use_case.call(
        room_id: room.id.value,
        start_time: start_time,
        end_time: end_time,
        responsible: 'João'
      )

      expect(result).to be_success
      expect(result.value!.responsible).to eq('João')
    end

    it 'returns not found when room does not exist' do
      allow(room_repository).to receive(:find_by_id).with('missing').and_return(nil)

      result = use_case.call(room_id: 'missing', start_time: start_time, end_time: end_time, responsible: 'João')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:not_found)
    end

    it 'returns conflict when room is not available' do
      allow(room_repository).to receive(:find_by_id).with(room.id.value).and_return(room)
      allow(reservation_repository).to receive(:has_overlapping?).and_return(true)

      result = use_case.call(
        room_id: room.id.value,
        start_time: start_time,
        end_time: end_time,
        responsible: 'João'
      )

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:conflict)
    end

    it 'returns validation error for invalid data' do
      allow(room_repository).to receive(:find_by_id).with(room.id.value).and_return(room)

      result = use_case.call(
        room_id: room.id.value,
        start_time: start_time,
        end_time: start_time,
        responsible: 'João'
      )

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:unprocessable_entity)
    end

    it 'creates a reservation from ISO 8601 strings' do
      allow(room_repository).to receive(:find_by_id).with(room.id.value).and_return(room)
      allow(reservation_repository).to receive(:has_overlapping?).and_return(false)
      allow(reservation_repository).to receive(:add)

      result = use_case.call(
        room_id: room.id.value,
        start_time: start_time.iso8601,
        end_time: end_time.iso8601,
        responsible: 'João'
      )

      expect(result).to be_success
    end
  end
end
