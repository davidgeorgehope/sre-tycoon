class CreateCompanies < ActiveRecord::Migration[7.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :scenario, null: false, default: 'startup'
      t.integer :turn, default: 1
      t.integer :action_points, default: 3
      t.float :budget, default: 500000.0
      t.integer :headcount, default: 5
      t.float :tech_debt, default: 10.0
      t.float :morale, default: 80.0
      t.float :uptime, default: 99.9
      t.float :revenue, default: 0.0
      t.integer :customers, default: 0
      t.integer :observability_level, default: 1
      t.boolean :slo_defined, default: false
      t.boolean :chaos_engineering, default: false
      t.boolean :game_over, default: false
      t.string :game_over_reason
      t.integer :score, default: 0
      t.integer :low_uptime_streak, default: 0
      t.integer :feature_pressure, default: 0
      t.float :oncall_burden, default: 20.0
      t.timestamps
    end
  end
end
