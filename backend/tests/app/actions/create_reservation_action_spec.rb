# frozen_string_literal: true

require_relative '../../../src/app/actions/create_reservation_action'
require_relative '../../support/action_integration_helper'

RSpec.describe App::Actions::CreateReservationAction do
  include_context 'with reservation action integration'

  let(:action) { described_class.new }
  let(:room) { DatabaseHelper.create_room }
  let(:start_time) { DateTime.now + 2 }
  let(:end_time) { start_time + Rational(1, 24) }

  describe '#call' do
    it 'returns 201 on success' do
      result = action.call(
        room_id: room.id.value,
        start_time: start_time,
        end_time: end_time,
        responsible: 'Maria'
      )

      expect(result[:status]).to eq(201)
      expect(result[:body][:responsible]).to eq('Maria')
      expect(result[:body][:room_id]).to eq(room.id.value)
    end

    it 'returns 404 when room does not exist' do
      result = action.call(
        room_id: '00000000-0000-0000-0000-000000000000',
        start_time: start_time,
        end_time: end_time,
        responsible: 'Maria'
      )

      expect(result[:status]).to eq(404)
    end

    it 'returns 422 on validation error' do
      result = action.call(
        room_id: room.id.value,
        start_time: start_time,
        end_time: start_time,
        responsible: 'Maria'
      )

      expect(result[:status]).to eq(422)
    end
  end
end
