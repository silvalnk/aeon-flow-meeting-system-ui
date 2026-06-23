# frozen_string_literal: true

module Auth
  module Application
    module Repositories
      class UserRepository
        def find_by_email(email)
          raise NotImplementedError
        end

        def add(entity)
          raise NotImplementedError
        end
      end
    end
  end
end
