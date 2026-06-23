# frozen_string_literal: true

require 'bcrypt'

require_relative '../../../src/app/actions/login_action'
require_relative '../../../src/lib/auth/app_container'
require_relative '../../../src/lib/auth/application/repositories/user_repository'
require_relative '../../../src/lib/auth/domain/entities/user_entity'

RSpec.describe App::Actions::LoginAction do
  let(:action) { described_class.new }
  let(:user_repository) { instance_double(Auth::Application::Repositories::UserRepository) }

  before do
    allow(Auth::AppContainer).to receive(:resolve).with('auth.infrastructure.user_repository').and_return(user_repository)
  end

  describe '#call' do
    it 'returns 200 with token on valid credentials' do
      user = Auth::Domain::Entities::User.new(
        email: 'admin@aeonflow.com',
        password_digest: BCrypt::Password.create('admin123'),
        name: 'Admin'
      )
      allow(user_repository).to receive(:find_by_email).with('admin@aeonflow.com').and_return(user)

      result = action.call(email: 'admin@aeonflow.com', password: 'admin123')

      expect(result[:status]).to eq(200)
      expect(result[:body][:token]).not_to be_nil
      expect(result[:body][:user][:email]).to eq('admin@aeonflow.com')
    end

    it 'returns 401 on invalid credentials' do
      allow(user_repository).to receive(:find_by_email).and_return(nil)

      result = action.call(email: 'unknown@example.com', password: 'wrong')

      expect(result[:status]).to eq(401)
      expect(result[:body][:error]).not_to be_nil
    end
  end
end
