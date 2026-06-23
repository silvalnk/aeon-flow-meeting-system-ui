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

puts 'Seeding completed.'
