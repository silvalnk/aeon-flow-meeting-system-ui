# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/app_container'
require_relative '../../../../../src/lib/reservations/application/use_cases/cancel_reservation_use_case'
require_relative '../../../../../src/lib/reservations/application/repositories/reservation_repository'
require_relative '../../../../../src/lib/reservations/domain/entities/reservation_entity'
require_relative '../../../../../src/lib/shared_domain/infrastructure/unit_of_work'

RSpec.describe Reservations::Application::UseCases::CancelReservationUseCase do
  let(:reservation_repository) { instance_double(Reservations::Application::Repositories::ReservationRepository) }
  let(:unit_of_work) { instance_double(SharedDomain::Infrastructure::UnitOfWork) }
  let(:use_case) { described_class.new }

  before do
    allow(Reservations::AppContainer).to receive(:resolve).with('reservations.infrastructure.reservation_repository').and_return(reservation_repository)
    allow(Reservations::AppContainer).to receive(:resolve).with('infrastructure.unit_of_work').and_return(unit_of_work)
    allow(unit_of_work).to receive(:transaction).and_yield
  end

  describe '#call' do
    it 'cancels a reservation with sufficient advance notice' do
      start_time = DateTime.now + 3
      existing = Reservations::Domain::Entities::Reservation.new(
        room_id: 'room-1',
        start_time: start_time,
        end_time: start_time + Rational(1, 24),
        responsible: 'Maria',
        status: 'pending',
        persisted: true
      )
      allow(reservation_repository).to receive(:find_by_id).and_return(existing)
      allow(reservation_repository).to receive(:update)

      result = use_case.call(room_id: 'room-1', id: existing.id.value)

      expect(result).to be_success
    end

    it 'returns not found when reservation does not exist' do
      allow(reservation_repository).to receive(:find_by_id).and_return(nil)

      result = use_case.call(room_id: 'room-1', id: 'missing')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:not_found)
    end

    it 'returns error when reservation is already cancelled' do
      start_time = DateTime.now + 3
      existing = Reservations::Domain::Entities::Reservation.new(
        room_id: 'room-1',
        start_time: start_time,
        end_time: start_time + Rational(1, 24),
        responsible: 'Maria',
        status: 'cancelled',
        persisted: true
      )
      allow(reservation_repository).to receive(:find_by_id).and_return(existing)

      result = use_case.call(room_id: 'room-1', id: existing.id.value)

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:unprocessable_entity)
    end

    it 'returns error when cancellation is within 24 hours' do
      start_time = DateTime.now + Rational(12, 24)
      existing = Reservations::Domain::Entities::Reservation.new(
        room_id: 'room-1',
        start_time: start_time,
        end_time: start_time + Rational(1, 24),
        responsible: 'Maria',
        status: 'pending',
        persisted: true
      )
      allow(reservation_repository).to receive(:find_by_id).and_return(existing)

      result = use_case.call(room_id: 'room-1', id: existing.id.value)

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:unprocessable_entity)
      expect(result.failure[:message]).to include('24 hours')
    end
  end
end
