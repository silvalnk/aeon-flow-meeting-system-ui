# frozen_string_literal: true

require 'bcrypt'

require_relative '../../../../../src/lib/auth/app_container'
require_relative '../../../../../src/lib/auth/application/use_cases/login_use_case'
require_relative '../../../../../src/lib/auth/application/repositories/user_repository'
require_relative '../../../../../src/lib/auth/domain/entities/user_entity'

RSpec.describe Auth::Application::UseCases::LoginUseCase do
  let(:user_repository) { instance_double(Auth::Application::Repositories::UserRepository) }
  let(:use_case) { described_class.new }

  before do
    allow(Auth::AppContainer).to receive(:resolve).with('auth.infrastructure.user_repository').and_return(user_repository)
  end

  describe '#call' do
    it 'returns token and user on valid credentials' do
      user = Auth::Domain::Entities::User.new(
        email: 'admin@aeonflow.com',
        password_digest: BCrypt::Password.create('admin123'),
        name: 'Admin'
      )
      allow(user_repository).to receive(:find_by_email).with('admin@aeonflow.com').and_return(user)

      result = use_case.call(email: 'admin@aeonflow.com', password: 'admin123')

      expect(result).to be_success
      expect(result.value![:token]).not_to be_nil
      expect(result.value![:user][:email]).to eq('admin@aeonflow.com')
    end

    it 'returns unauthorized when user is not found' do
      allow(user_repository).to receive(:find_by_email).and_return(nil)

      result = use_case.call(email: 'unknown@example.com', password: 'wrong')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:unauthorized)
    end

    it 'returns unauthorized when password is wrong' do
      user = Auth::Domain::Entities::User.new(
        email: 'admin@aeonflow.com',
        password_digest: BCrypt::Password.create('admin123'),
        name: 'Admin'
      )
      allow(user_repository).to receive(:find_by_email).and_return(user)

      result = use_case.call(email: 'admin@aeonflow.com', password: 'wrongpassword')

      expect(result).to be_failure
      expect(result.failure[:status]).to eq(:unauthorized)
    end
  end
end
