# frozen_string_literal: true

require_relative '../../../src/app/actions/cancel_reservation_action'
require_relative '../../../src/lib/reservations/infrastructure/repositories/sqlite_reservation_repository'
require_relative '../../../src/lib/reservations/domain/entities/reservation_entity'
require_relative '../../support/action_integration_helper'

RSpec.describe App::Actions::CancelReservationAction do
  include_context 'with reservation action integration'

  let(:action) { described_class.new }
  let(:repository) { Reservations::Infrastructure::Repositories::SqliteReservationRepository.new }
  let(:room) { DatabaseHelper.create_room }

  def create_reservation(start_days: 3)
    start_time = DateTime.now + start_days
    reservation = Reservations::Domain::Entities::Reservation.new(
      room_id: room.id.value,
      start_time: start_time,
      end_time: start_time + Rational(1, 24),
      responsible: 'Maria'
    )
    repository.add(reservation)
    reservation
  end

  describe '#call' do
    it 'returns 204 when cancellation is allowed' do
      reservation = create_reservation

      result = action.call(room_id: room.id.value, id: reservation.id.value)

      expect(result[:status]).to eq(204)
      expect(result[:body]).to be_nil
    end

    it 'returns 404 when reservation does not exist' do
      result = action.call(room_id: room.id.value, id: '00000000-0000-0000-0000-000000000000')

      expect(result[:status]).to eq(404)
    end

    it 'returns 422 when cancellation is within 24 hours' do
      reservation = create_reservation(start_days: Rational(12, 24))

      result = action.call(room_id: room.id.value, id: reservation.id.value)

      expect(result[:status]).to eq(422)
    end
  end
end
