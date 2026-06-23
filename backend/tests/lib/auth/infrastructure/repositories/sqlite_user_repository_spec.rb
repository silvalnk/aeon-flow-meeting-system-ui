# frozen_string_literal: true

require 'bcrypt'
require_relative '../../../../../src/lib/auth/infrastructure/repositories/sqlite_user_repository'
require_relative '../../../../../src/lib/auth/domain/entities/user_entity'
require_relative '../../../../support/database_helper'

RSpec.describe Auth::Infrastructure::Repositories::SqliteUserRepository do
  let(:rom) { DatabaseHelper.rom }
  let(:repository) { described_class.new }

  before do
    DatabaseHelper.truncate_all!
    allow(Auth::AppContainer).to receive(:resolve).with('infrastructure.rom').and_return(rom)
  end

  after do
    rom.container.disconnect
  end

  describe '#add and #find_by_email' do
    it 'persists and retrieves a user' do
      user = Auth::Domain::Entities::User.new(
        email: 'test@example.com',
        password_digest: BCrypt::Password.create('secret'),
        name: 'Test User'
      )
      repository.add(user)

      found = repository.find_by_email('test@example.com')

      expect(found).not_to be_nil
      expect(found.name).to eq('Test User')
      expect(found.authenticate('secret')).to be true
    end

    it 'returns nil when user does not exist' do
      expect(repository.find_by_email('missing@example.com')).to be_nil
    end
  end
end
