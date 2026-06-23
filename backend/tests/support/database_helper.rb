# frozen_string_literal: true

require 'sequel'
require_relative '../../src/lib/shared_domain/infrastructure/rom'
require_relative '../../src/lib/rooms/domain/entities/room_entity'

module DatabaseHelper
  module_function

  def db_path
    File.expand_path('../src/database/database_test.sqlite3', __dir__)
  end

  def migrate!
    Sequel.extension :migration
    db = Sequel.sqlite(db_path)
    Sequel::Migrator.run(db, File.expand_path('../src/database/migrations', __dir__))
  end

  def rom
    @rom ||= SharedDomain::Infrastructure::Rom.new(environment: 'test')
  end

  def truncate_all!
    %i[reservations rooms users].each do |table|
      rom.db[table].truncate if rom.db.table_exists?(table)
    end
  end

  def create_room(attrs = {})
    room = Rooms::Domain::Entities::Room.new({
      name: 'Test Room',
      capacity: 10,
      location: 'Floor 1'
    }.merge(attrs))

    rom[:rooms].command(:create).call(
      id: room.id.value,
      name: room.name,
      capacity: room.capacity,
      location: room.location
    )
    room
  end

  def future_datetime(days_from_now = 2)
    DateTime.now + days_from_now
  end
end
