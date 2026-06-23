# frozen_string_literal: true

require_relative '../../../../../src/lib/reservations/domain/entities/reservation_entity'
require_relative '../../../../../src/lib/reservations/domain/errors/reservation_validation_error'

RSpec.describe Reservations::Domain::Entities::Reservation, type: :entity do
  let(:valid_attrs) do
    {
      room_id: '550e8400-e29b-41d4-a716-446655440000',
      start_time: future_datetime(2),
      end_time: future_datetime(2) + Rational(1, 24),
      responsible: 'João Silva',
      description: 'Planning meeting'
    }
  end

  describe '#initialize' do
    context 'with valid attributes' do
      it 'creates a new reservation' do
        reservation = described_class.new(valid_attrs)

        expect(reservation.responsible).to eq('João Silva')
        expect(reservation.status).to eq('pending')
      end

      it 'accepts ISO 8601 strings for start_time and end_time' do
        start_time = future_datetime(2)
        end_time = start_time + Rational(1, 24)

        reservation = described_class.new(valid_attrs.merge(
          start_time: start_time.iso8601,
          end_time: end_time.iso8601
        ))

        expect(reservation.start_time).to be_a(DateTime)
        expect(reservation.end_time).to be_a(DateTime)
      end
    end

    context 'with invalid attributes' do
      it 'raises when end_time is before start_time' do
        expect {
          described_class.new(valid_attrs.merge(end_time: valid_attrs[:start_time] - Rational(1, 24)))
        }.to raise_error(Reservations::Domain::Errors::ReservationValidationError)
      end

      it 'raises when start_time is in the past' do
        expect {
          described_class.new(valid_attrs.merge(
            start_time: DateTime.now - 1,
            end_time: DateTime.now + Rational(1, 24)
          ))
        }.to raise_error(Reservations::Domain::Errors::ReservationValidationError)
      end

      it 'raises when responsible is missing' do
        expect {
          described_class.new(valid_attrs.merge(responsible: ''))
        }.to raise_error(Reservations::Domain::Errors::ReservationValidationError)
      end
    end

    context 'when reconstituted from persistence' do
      it 'skips validation with persisted flag' do
        reservation = described_class.new(valid_attrs.merge(
          start_time: DateTime.now - 1,
          end_time: DateTime.now + Rational(1, 24),
          persisted: true
        ))

        expect(reservation.responsible).to eq('João Silva')
      end
    end
  end

  describe '#cancelled?' do
    it 'returns true when status is cancelled' do
      reservation = described_class.new(valid_attrs.merge(status: 'cancelled', persisted: true))
      expect(reservation.cancelled?).to be true
    end
  end
end
