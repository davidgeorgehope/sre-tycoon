class CreateScores < ActiveRecord::Migration[7.1]
  def change
    create_table :scores do |t|
      t.string :company_name, null: false
      t.string :scenario, null: false
      t.integer :turns_to_completion
      t.integer :final_score, default: 0
      t.float :final_revenue, default: 0.0
      t.float :final_uptime, default: 0.0
      t.integer :final_headcount, default: 0
      t.boolean :won, default: false
      t.datetime :completed_at
      t.timestamps
    end
  end
end
