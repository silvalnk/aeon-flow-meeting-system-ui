# frozen_string_literal: true

require_relative '../../../src/app/serializers/reservation_serializer'
require_relative '../../../src/lib/reservations/domain/entities/reservation_entity'

RSpec.describe App::Serializers::ReservationSerializer do
  let(:start_time) { DateTime.now + 2 }
  let(:end_time) { start_time + Rational(1, 24) }
  let(:reservation) do
    Reservations::Domain::Entities::Reservation.new(
      room_id: 'room-1',
      start_time: start_time,
      end_time: end_time,
      description: 'Team meeting',
      responsible: 'Maria',
      status: 'pending'
    )
  end

  describe '.serialize' do
    it 'serializes a reservation entity' do
      result = described_class.serialize(reservation)

      expect(result[:id]).to eq(reservation.id.value)
      expect(result[:room_id]).to eq('room-1')
      expect(result[:start_time]).to eq(start_time.iso8601)
      expect(result[:end_time]).to eq(end_time.iso8601)
      expect(result[:description]).to eq('Team meeting')
      expect(result[:responsible]).to eq('Maria')
      expect(result[:status]).to eq('pending')
    end
  end

  describe '.serialize_collection' do
    it 'serializes a collection of reservations' do
      result = described_class.serialize_collection([reservation])

      expect(result.length).to eq(1)
      expect(result.first[:responsible]).to eq('Maria')
    end
  end
end
