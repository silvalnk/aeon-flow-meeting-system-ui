# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/app_container'
require_relative '../../../../../src/lib/reservations/application/use_cases/get_reservation_use_case'
require_relative '../../../../../src/lib/reservations/application/repositories/reservation_repository'
require_relative '../../../../../src/lib/reservations/domain/entities/reservation_entity'

RSpec.describe Reservations::Application::UseCases::GetReservationUseCase do
  let(:reservation_repository) { instance_double(Reservations::Application::Repositories::ReservationRepository) }
  let(:use_case) { described_class.new }

  before do
    allow(Reservations::AppContainer).to receive(:resolve).with('reservations.infrastructure.reservation_repository').and_return(reservation_repository)
  end

  describe '#call' do
    it 'returns the reservation when found' do
      reservation = Reservations::Domain::Entities::Reservation.new(
        room_id: 'room-1',
        start_time: future_datetime(2),
        end_time: future_datetime(2) + Rational(1, 24),
        responsible: 'Maria',
        persisted: true
      )
      allow(reservation_repository).to receive(:find_by_id).with('room-1', reservation.id.value).and_return(reservation)

      result = use_case.call(room_id: 'room-1', id: reservation.id.value)

      expect(result).to be_success
      expect(result.value!).to eq(reservation)
    end

    it 'returns not found when reservation does not exist' do
      allow(reservation_repository).to receive(:find_by_id).with('room-1', 'missing').and_return(nil)

      result = use_case.call(room_id: 'room-1', id: 'missing')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:not_found)
    end
  end
end
