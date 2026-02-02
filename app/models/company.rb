class Company < ApplicationRecord
  has_many :turns, dependent: :destroy

  validates :name, presence: true
  validates :scenario, presence: true, inclusion: { in: %w[startup series_a enterprise] }

  SCENARIOS = {
    'startup' => {
      label: '🚀 Bootstrapped Startup',
      description: 'Three engineers in a garage. $500K in savings. A dream and a whiteboard.',
      budget: 500_000, headcount: 3, tech_debt: 5.0, morale: 95.0,
      uptime: 99.5, revenue: 10_000, customers: 50, observability_level: 0
    },
    'series_a' => {
      label: '💰 Series A Rocket Ship',
      description: '$5M in the bank. 15 engineers. VCs asking "when unicorn?" every board meeting.',
      budget: 5_000_000, headcount: 15, tech_debt: 25.0, morale: 75.0,
      uptime: 99.5, revenue: 500_000, customers: 2000, observability_level: 2
    },
    'enterprise' => {
      label: '🏢 Enterprise Legacy Beast',
      description: '200 engineers. $50M budget. 40% tech debt. The monolith has its own gravitational field.',
      budget: 50_000_000, headcount: 200, tech_debt: 40.0, morale: 60.0,
      uptime: 99.0, revenue: 5_000_000, customers: 50000, observability_level: 3
    }
  }.freeze

  def arr
    revenue * 12
  end

  def ipo_ready?
    arr > 10_000_000 && uptime > 99.9 && headcount > 50
  end

  def alive?
    !game_over?
  end

  def metrics_hash
    {
      turn: turn,
      budget: budget,
      headcount: headcount,
      tech_debt: tech_debt,
      morale: morale,
      uptime: uptime,
      revenue: revenue,
      customers: customers,
      observability_level: observability_level,
      slo_defined: slo_defined,
      oncall_burden: oncall_burden,
      arr: arr
    }
  end

  def format_budget
    if budget >= 1_000_000
      "$#{(budget / 1_000_000.0).round(2)}M"
    elsif budget >= 1_000
      "$#{(budget / 1_000.0).round(1)}K"
    else
      "$#{budget.round(0)}"
    end
  end

  def format_revenue
    if revenue >= 1_000_000
      "$#{(revenue / 1_000_000.0).round(2)}M/mo"
    elsif revenue >= 1_000
      "$#{(revenue / 1_000.0).round(1)}K/mo"
    else
      "$#{revenue.round(0)}/mo"
    end
  end

  def format_arr
    if arr >= 1_000_000
      "$#{(arr / 1_000_000.0).round(2)}M"
    elsif arr >= 1_000
      "$#{(arr / 1_000.0).round(1)}K"
    else
      "$#{arr.round(0)}"
    end
  end
end
