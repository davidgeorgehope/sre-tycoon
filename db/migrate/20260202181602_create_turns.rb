class CreateTurns < ActiveRecord::Migration[7.1]
  def change
    create_table :turns do |t|
      t.references :company, null: false, foreign_key: true
      t.integer :turn_number, null: false
      t.text :actions_taken
      t.text :events
      t.text :metrics_snapshot
      t.timestamps
    end
  end
end
