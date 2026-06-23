# frozen_string_literal: true

require_relative '../../../src/app/actions/delete_room_action'
require_relative '../../support/action_integration_helper'

RSpec.describe App::Actions::DeleteRoomAction do
  include_context 'with room action integration'

  let(:action) { described_class.new }

  describe '#call' do
    it 'returns 204 when room is deleted' do
      room = DatabaseHelper.create_room

      result = action.call(id: room.id.value)

      expect(result[:status]).to eq(204)
      expect(result[:body]).to be_nil
    end

    it 'returns 404 when room does not exist' do
      result = action.call(id: '00000000-0000-0000-0000-000000000000')

      expect(result[:status]).to eq(404)
    end
  end
end
