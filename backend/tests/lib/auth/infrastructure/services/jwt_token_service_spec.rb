# frozen_string_literal: true

require_relative '../../../../../src/lib/auth/infrastructure/services/jwt_token_service'

RSpec.describe Auth::Infrastructure::Services::JwtTokenService do
  describe '.encode and .decode' do
    it 'encodes and decodes a valid token' do
      token = described_class.encode('user-123', 'test@example.com')
      payload = described_class.decode(token)

      expect(payload['sub']).to eq('user-123')
      expect(payload['email']).to eq('test@example.com')
      expect(payload['exp']).to be > Time.now.to_i
    end

    it 'returns nil for an invalid token' do
      expect(described_class.decode('invalid.token.here')).to be_nil
    end
  end
end
