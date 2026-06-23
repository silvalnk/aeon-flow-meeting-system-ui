# frozen_string_literal: true

require_relative '../../../src/app/actions/get_room_action'
require_relative '../../support/action_integration_helper'

RSpec.describe App::Actions::GetRoomAction do
  include_context 'with room action integration'

  let(:action) { described_class.new }

  describe '#call' do
    it 'returns 200 when room exists' do
      room = DatabaseHelper.create_room(name: 'Alpha', capacity: 10, location: 'A')

      result = action.call(id: room.id.value)

      expect(result[:status]).to eq(200)
      expect(result[:body][:name]).to eq('Alpha')
    end

    it 'returns 404 when room does not exist' do
      result = action.call(id: '00000000-0000-0000-0000-000000000000')

      expect(result[:status]).to eq(404)
      expect(result[:body][:error]).not_to be_nil
    end
  end
end
