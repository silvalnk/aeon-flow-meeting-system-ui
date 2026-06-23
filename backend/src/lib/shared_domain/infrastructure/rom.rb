# frozen_string_literal: true

require 'sequel'
require 'rom'
require 'rom-sql'
require 'rom-repository'

require_relative '../../../app/initializers/environment'

module SharedDomain
  module Infrastructure
    class Rom
      attr_reader :container, :db

      def initialize(environment: ENV['ENVIRONMENT'])
        @environment = environment
        @db = setup_database
        @container = setup_rom
      end

      def [](relation_name)
        @container.relations[relation_name]
      end

      private

      def setup_database
        db_path = File.expand_path("../../../database/database_#{@environment}.sqlite3", __dir__)
        Sequel.sqlite(db_path)
      end

      def setup_rom
        config = ROM::Configuration.new(:sql, @db)
        config.relation(:rooms) { schema(infer: true) }
        config.relation(:reservations) { schema(infer: true) }
        config.relation(:users) { schema(infer: true) }
        ROM.container(config)
      end
    end
  end
end

