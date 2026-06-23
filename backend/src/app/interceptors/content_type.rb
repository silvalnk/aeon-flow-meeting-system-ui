# frozen_string_literal: true

module App
  module Interceptors
    class ContentType
      def initialize(app)
        @app = app
      end

      def call(env)
        status, headers, body = @app.call(env)
        headers['Content-Type'] = 'application/json' if json_response?(env, status, headers)
        [status, headers, body]
      end

      private

      def json_response?(env, status, headers)
        return false if env['REQUEST_METHOD'] == 'OPTIONS'
        return false if status == 204
        return false if headers['Content-Type']

        true
      end
    end
  end
end
