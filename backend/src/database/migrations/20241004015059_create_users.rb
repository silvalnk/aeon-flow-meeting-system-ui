# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:users) do
      String :id, primary_key: true
      String :email, null: false, unique: true
      String :password_digest, null: false
      String :name, null: false
    end
  end

  down do
    drop_table(:users)
  end
end
