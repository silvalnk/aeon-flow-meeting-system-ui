# frozen_string_literal: true

require_relative '../../../src/app/interceptors/auth'
require_relative '../../../src/lib/auth/infrastructure/services/jwt_token_service'

RSpec.describe App::Interceptors::Auth do
  let(:app) { ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }
  let(:middleware) { described_class.new(app) }

  def call_middleware(path, method, headers = {})
    env = {
      'PATH_INFO' => path,
      'REQUEST_METHOD' => method
    }.merge(headers)
    middleware.call(env)
  end

  describe '#call' do
    it 'allows public GET /api/v1/rooms without token' do
      status, = call_middleware('/api/v1/rooms', 'GET')

      expect(status).to eq(200)
    end

    it 'allows public GET /api/v1/rooms/{uuid} without token' do
      status, = call_middleware('/api/v1/rooms/41aa4c60-50a7-013f-fdf2-00155de0420b', 'GET')

      expect(status).to eq(200)
    end

    it 'allows public GET reservation by id without token' do
      path = '/api/v1/rooms/41aa4c60-50a7-013f-fdf2-00155de0420b/reservations/660e8400-e29b-41d4-a716-446655440001'
      status, = call_middleware(path, 'GET')

      expect(status).to eq(200)
    end

    it 'allows public GET /api/v1/reservations without token' do
      status, = call_middleware('/api/v1/reservations', 'GET')

      expect(status).to eq(200)
    end

    it 'allows OPTIONS preflight without token' do
      status, = call_middleware('/api/v1/rooms/abc-123', 'OPTIONS')

      expect(status).to eq(200)
    end

    it 'allows POST /api/v1/auth/login without token' do
      status, = call_middleware('/api/v1/auth/login', 'POST')

      expect(status).to eq(200)
    end

    it 'returns 401 for protected PUT without token' do
      status, headers, body = call_middleware('/api/v1/rooms/abc-123', 'PUT')

      expect(status).to eq(401)
      expect(headers['Content-Type']).to eq('application/json')
      expect(JSON.parse(body.first)['error']).to eq('Unauthorized')
    end

    it 'allows protected requests with valid bearer token' do
      token = Auth::Infrastructure::Services::JwtTokenService.encode('user-1', 'admin@aeonflow.com')

      status, = call_middleware('/api/v1/rooms/abc-123', 'PUT', 'HTTP_AUTHORIZATION' => "Bearer #{token}")

      expect(status).to eq(200)
    end

    it 'returns 401 for invalid bearer token' do
      status, = call_middleware('/api/v1/rooms/abc-123', 'PUT', 'HTTP_AUTHORIZATION' => 'Bearer invalid-token')

      expect(status).to eq(401)
    end
  end
end
