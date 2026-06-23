# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/app_container'
require_relative '../../../../../src/lib/reservations/application/use_cases/update_reservation_use_case'
require_relative '../../../../../src/lib/reservations/application/repositories/reservation_repository'
require_relative '../../../../../src/lib/reservations/domain/entities/reservation_entity'
require_relative '../../../../../src/lib/shared_domain/infrastructure/unit_of_work'

RSpec.describe Reservations::Application::UseCases::UpdateReservationUseCase do
  let(:reservation_repository) { instance_double(Reservations::Application::Repositories::ReservationRepository) }
  let(:unit_of_work) { instance_double(SharedDomain::Infrastructure::UnitOfWork) }
  let(:use_case) { described_class.new }
  let(:start_time) { future_datetime(2) }
  let(:end_time) { start_time + Rational(1, 24) }
  let(:existing) do
    Reservations::Domain::Entities::Reservation.new(
      room_id: 'room-1',
      start_time: start_time,
      end_time: end_time,
      responsible: 'Maria',
      status: 'pending',
      persisted: true
    )
  end

  before do
    allow(Reservations::AppContainer).to receive(:resolve).with('reservations.infrastructure.reservation_repository').and_return(reservation_repository)
    allow(Reservations::AppContainer).to receive(:resolve).with('infrastructure.unit_of_work').and_return(unit_of_work)
    allow(unit_of_work).to receive(:transaction).and_yield
  end

  describe '#call' do
    it 'updates an existing reservation' do
      allow(reservation_repository).to receive(:find_by_id).and_return(existing)
      allow(reservation_repository).to receive(:has_overlapping?).and_return(false)
      allow(reservation_repository).to receive(:update)

      result = use_case.call(
        room_id: 'room-1',
        id: existing.id.value,
        responsible: 'Pedro',
        status: 'confirmed'
      )

      expect(result).to be_success
      expect(result.value!.responsible).to eq('Pedro')
      expect(result.value!.status).to eq('confirmed')
    end

    it 'returns not found when reservation does not exist' do
      allow(reservation_repository).to receive(:find_by_id).and_return(nil)

      result = use_case.call(room_id: 'room-1', id: 'missing', responsible: 'Pedro')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:not_found)
    end

    it 'returns error when reservation is cancelled' do
      cancelled = Reservations::Domain::Entities::Reservation.new(
        room_id: 'room-1',
        start_time: start_time,
        end_time: end_time,
        responsible: 'Maria',
        status: 'cancelled',
        persisted: true
      )
      allow(reservation_repository).to receive(:find_by_id).and_return(cancelled)

      result = use_case.call(room_id: 'room-1', id: cancelled.id.value, responsible: 'Pedro')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:unprocessable_entity)
    end

    it 'returns conflict when time slot overlaps' do
      allow(reservation_repository).to receive(:find_by_id).and_return(existing)
      allow(reservation_repository).to receive(:has_overlapping?).and_return(true)

      new_start = future_datetime(3)
      result = use_case.call(
        room_id: 'room-1',
        id: existing.id.value,
        start_time: new_start,
        end_time: new_start + Rational(1, 24),
        responsible: 'Maria'
      )

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:conflict)
    end
  end
end
