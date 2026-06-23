# frozen_string_literal: true

module App
  module Interceptors
    class Cors
      def initialize(app)
        @app = app
      end

      def call(env)
        return options_response if env['REQUEST_METHOD'] == 'OPTIONS'

        status, headers, body = @app.call(env)
        headers['access-control-allow-origin'] = '*' unless headers['access-control-allow-origin']
        headers['access-control-allow-headers'] = '*' unless headers['access-control-allow-headers']
        headers['access-control-allow-methods'] = '*' unless headers['access-control-allow-methods']
        [status, headers, body]
      end

      private

      def options_response
        [204, cors_headers, []]
      end

      def cors_headers
        {
          'access-control-allow-origin' => '*',
          'access-control-allow-headers' => '*',
          'access-control-allow-methods' => '*'
        }
      end
    end
  end
end
