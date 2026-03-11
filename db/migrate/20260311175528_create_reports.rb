class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.string :location, null: false
      t.integer :severity, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.datetime :reported_at, null: false
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :assignee, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :reports, :severity
    add_index :reports, :status
    add_index :reports, :location
  end
end
