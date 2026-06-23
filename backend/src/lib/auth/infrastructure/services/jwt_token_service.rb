# frozen_string_literal: true

require 'jwt'

module Auth
  module Infrastructure
    module Services
      module JwtTokenService
        SECRET = ENV.fetch('JWT_SECRET', 'aeon-flow-meeting-system-secret-key')
        EXPIRATION = 24 * 60 * 60

        module_function

        def encode(user_id, email)
          payload = {
            sub: user_id,
            email: email,
            exp: Time.now.to_i + EXPIRATION
          }
          JWT.encode(payload, SECRET, 'HS256')
        end

        def decode(token)
          JWT.decode(token, SECRET, true, algorithm: 'HS256').first
        rescue JWT::DecodeError, JWT::ExpiredSignature
          nil
        end
      end
    end
  end
end
