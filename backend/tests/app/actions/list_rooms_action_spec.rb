# frozen_string_literal: true

require_relative '../../../src/app/actions/list_rooms_action'
require_relative '../../support/action_integration_helper'

RSpec.describe App::Actions::ListRoomsAction do
  include_context 'with room action integration'

  let(:action) { described_class.new }

  describe '#call' do
    it 'returns 200 with all rooms' do
      DatabaseHelper.create_room(name: 'Alpha', capacity: 10, location: 'A')
      DatabaseHelper.create_room(name: 'Beta', capacity: 20, location: 'B')

      result = action.call

      expect(result[:status]).to eq(200)
      expect(result[:body].length).to eq(2)
      expect(result[:body].map { |r| r[:name] }).to contain_exactly('Alpha', 'Beta')
    end

    it 'filters rooms by search term' do
      DatabaseHelper.create_room(name: 'Alpha', capacity: 10, location: 'A')
      DatabaseHelper.create_room(name: 'Beta', capacity: 20, location: 'B')

      result = action.call(search: 'Alpha')

      expect(result[:status]).to eq(200)
      expect(result[:body].length).to eq(1)
      expect(result[:body].first[:name]).to eq('Alpha')
    end
  end
end
