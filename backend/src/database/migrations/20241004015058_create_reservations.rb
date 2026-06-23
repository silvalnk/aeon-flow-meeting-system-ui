# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:reservations) do
      String :id, primary_key: true
      String :room_id, null: false
      DateTime :start_time, null: false
      DateTime :end_time, null: false
      Text :description
      String :responsible, null: false
      String :status, null: false, default: 'pending'

      foreign_key [:room_id], :rooms, key: :id, on_delete: :cascade
      index :room_id
      index :status
      index %i[room_id start_time end_time]
    end
  end

  down do
    drop_table(:reservations)
  end
end
