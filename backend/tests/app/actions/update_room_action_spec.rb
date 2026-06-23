# frozen_string_literal: true

require_relative '../../../src/app/actions/update_room_action'
require_relative '../../support/action_integration_helper'

RSpec.describe App::Actions::UpdateRoomAction do
  include_context 'with room action integration'

  let(:action) { described_class.new }

  describe '#call' do
    it 'returns 200 when room is updated' do
      room = DatabaseHelper.create_room(name: 'Alpha', capacity: 10, location: 'A')

      result = action.call(id: room.id.value, name: 'Beta', capacity: 15, location: 'B')

      expect(result[:status]).to eq(200)
      expect(result[:body][:name]).to eq('Beta')
      expect(result[:body][:capacity]).to eq(15)
    end

    it 'returns 404 when room does not exist' do
      result = action.call(
        id: '00000000-0000-0000-0000-000000000000',
        name: 'Beta',
        capacity: 15,
        location: 'B'
      )

      expect(result[:status]).to eq(404)
    end

    it 'returns 422 on validation error' do
      room = DatabaseHelper.create_room

      result = action.call(id: room.id.value, name: '', capacity: 10, location: 'A')

      expect(result[:status]).to eq(422)
      expect(result[:body]).to have_key(:errors)
    end
  end
end
