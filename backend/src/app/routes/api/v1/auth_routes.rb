# frozen_string_literal: true

require_relative '../../../actions/login_action'
require_relative '../../../../lib/shared_domain/web/routes'

module App
  module Routes
    module API
      module V1
        module AuthRoutes
          include SharedDomain::Web::Routes

          module_function

          def register(app)
            app.post '/api/v1/auth/login' do
              result = App::Actions::LoginAction.new.call(params)
              status result[:status]
              json(result[:body])
            end
          end
        end
      end
    end
  end
end
