# frozen_string_literal: true

require 'sequel'
require 'bcrypt'
require 'securerandom'

environment = ENV['ENVIRONMENT'] || 'development'
db_path = File.expand_path("database_#{environment}.sqlite3", __dir__)
db = Sequel.sqlite(db_path)

puts 'Seeding database...'

unless db[:users].where(email: 'admin@aeonflow.com').any?
  db[:users].insert(
    id: SecureRandom.uuid,
    email: 'admin@aeonflow.com',
    password_digest: BCrypt::Password.create('admin123'),
    name: 'Administrador'
  )
  puts 'Default admin user created: admin@aeonflow.com / admin123'
end

rooms_data = [
  { name: 'Sala Alpha', capacity: 10, location: 'Andar 1 - Ala Norte' },
  { name: 'Sala Beta', capacity: 20, location: 'Andar 2 - Ala Sul' },
  { name: 'Auditório', capacity: 100, location: 'Térreo' }
]

if db[:rooms].count.zero?
  rooms_data.each do |attrs|
    db[:rooms].insert(id: SecureRandom.uuid, **attrs)
    puts "Room created: #{attrs[:name]}"
  end
end

if db[:reservations].count.zero? && db[:rooms].any?
  rooms = db[:rooms].all
  first_room = rooms.first
  second_room = rooms[1] || first_room
  base = Time.now + (3 * 24 * 60 * 60)
  start_one = Time.new(base.year, base.month, base.day, 10, 0, 0)
  start_two = start_one + (24 * 60 * 60)

  db[:reservations].insert(
    id: SecureRandom.uuid,
    room_id: first_room[:id],
    start_time: start_one,
    end_time: start_one + 3600,
    description: 'Reunião de planejamento',
    responsible: 'Administrador',
    status: 'confirmed'
  )
  db[:reservations].insert(
    id: SecureRandom.uuid,
    room_id: second_room[:id],
    start_time: start_two,
    end_time: start_two + (2 * 3600),
    description: 'Alinhamento de squad',
    responsible: 'Ana Souza',
    status: 'pending'
  )
  puts 'Sample reservations created'
end

puts 'Seeding completed.'
