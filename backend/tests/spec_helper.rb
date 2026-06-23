# frozen_string_literal: true

require 'bundler/setup'
require 'sequel'
require 'fileutils'

require_relative '../src/app/initializers/environment'

DB_DIR = File.expand_path('../src/database', __dir__)
DB_PATH = File.join(DB_DIR, 'database_test.sqlite3')
MIGRATIONS_DIR = File.expand_path('../src/database/migrations', __dir__)

FileUtils.mkdir_p(DB_DIR)
FileUtils.chmod(0777, DB_DIR) if File.exist?(DB_DIR)
FileUtils.touch(DB_PATH) unless File.exist?(DB_PATH)

Sequel.extension :migration
Sequel::Migrator.run(Sequel.sqlite(DB_PATH), MIGRATIONS_DIR)

require_relative 'support/action_integration_helper'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.pattern = 'tests/**/*_spec.rb'

  config.include(Module.new do
    def future_datetime(days_from_now = 2)
      DateTime.now + days_from_now
    end
  end)
end
