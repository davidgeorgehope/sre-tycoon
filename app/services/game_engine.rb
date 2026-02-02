class GameEngine
  ACTIONS = {
    'ship_features' => {
      emoji: '🚀',
      label: 'Ship Features',
      description: 'Push code to prod. YOLO. Revenue goes up, tech debt follows.'
    },
    'pay_debt' => {
      emoji: '🔧',
      label: 'Pay Down Tech Debt',
      description: 'Refactor the monolith. Your future self will thank you.'
    },
    'observability' => {
      emoji: '📊',
      label: 'Invest in Observability',
      description: 'You can\'t fix what you can\'t see. Dashboards. Alerts. The works.'
    },
    'hire' => {
      emoji: '👥',
      label: 'Hire Engineers',
      description: 'More hands on deck. They\'ll need 2 sprints to ramp up though.'
    },
    'define_slos' => {
      emoji: '🎯',
      label: 'Define SLOs',
      description: 'Set targets that customers trust. Because "it works on my machine" isn\'t an SLO.'
    },
    'chaos_engineering' => {
      emoji: '🛡️',
      label: 'Chaos Engineering',
      description: 'Break things on purpose, before they break themselves at 3am.'
    },
    'team_building' => {
      emoji: '🎉',
      label: 'Team Building',
      description: 'Escape rooms, retros with actual action items, and free pizza.'
    },
    'fundraise' => {
      emoji: '💰',
      label: 'Fundraise',
      description: 'Take VC money. The board wants 10x growth. No pressure.'
    }
  }.freeze

  attr_reader :company, :log

  def initialize(company)
    @company = company
    @log = []
  end

  def perform_action(action_key)
    return { error: 'Game is over, mate.' } if company.game_over?
    return { error: 'No action points remaining this sprint.' } if company.action_points <= 0
    return { error: 'Unknown action.' } unless ACTIONS.key?(action_key)

    send("do_#{action_key}")
    company.action_points -= 1
    company.save!

    { success: true, message: @log.last }
  end

  def end_turn
    return { error: 'Game is over.' } if company.game_over?

    events = generate_events
    apply_passive_effects
    check_game_over_conditions
    calculate_score

    turn = company.turns.create!(
      turn_number: company.turn,
      actions_taken: (company.turns.last&.parsed_actions || []).to_json,
      events: events.to_json,
      metrics_snapshot: company.metrics_hash.to_json
    )

    unless company.game_over?
      company.turn += 1
      company.action_points = action_points_for_turn
    end

    company.save!

    { events: events, turn: turn }
  end

  private

  def action_points_for_turn
    base = 3
    base += 1 if company.headcount >= 20
    base += 1 if company.headcount >= 50
    [base, 5].min
  end

  # ─── Actions ──────────────────────────────────────────

  def do_ship_features
    revenue_boost = company.headcount * rand(500..2000) * (1 - company.tech_debt / 200.0)
    customer_boost = rand(10..50) * (company.headcount / 5.0).ceil
    debt_increase = rand(2.0..8.0)

    company.revenue += revenue_boost
    company.customers += customer_boost
    company.tech_debt = [company.tech_debt + debt_increase, 100].min
    company.morale -= rand(1.0..3.0) if company.tech_debt > 60

    @log << "[DEPLOY] Shipped features. Revenue +#{format_money(revenue_boost)}, +#{customer_boost} customers. Tech debt now #{company.tech_debt.round(1)}%."
  end

  def do_pay_debt
    reduction = rand(5.0..15.0) * (company.headcount / 10.0).clamp(0.5, 3.0)
    company.tech_debt = [company.tech_debt - reduction, 0].max
    company.morale += rand(1.0..3.0)
    company.morale = [company.morale, 100].min

    @log << "[REFACTOR] Paid down tech debt by #{reduction.round(1)}%. Engineers finally deleted that TODO from 2019."
  end

  def do_observability
    cost = 50_000 * (company.observability_level + 1)
    if company.budget < cost
      @log << "[ERROR] Can't afford observability upgrade. Need #{format_money(cost)}."
      company.action_points += 1 # refund
      return
    end

    company.budget -= cost
    company.observability_level = [company.observability_level + 1, 10].min
    company.oncall_burden = [company.oncall_burden - 5, 0].max

    @log << "[OBSERVE] Observability level → #{company.observability_level}. You can now see #{observability_flavor(company.observability_level)}."
  end

  def do_hire
    salary_cost = rand(80_000..150_000)
    if company.budget < salary_cost
      @log << "[ERROR] Can't afford to hire. Need #{format_money(salary_cost)}. Maybe try fundraising?"
      company.action_points += 1
      return
    end

    company.budget -= salary_cost
    company.headcount += 1
    company.morale += rand(1.0..2.0)
    company.morale = [company.morale, 100].min
    company.oncall_burden = [company.oncall_burden - 2, 5].max

    @log << "[HIRE] New engineer onboarded! Headcount → #{company.headcount}. They'll spend the first sprint asking where the docs are."
  end

  def do_define_slos
    if company.slo_defined?
      company.uptime += rand(0.1..0.3)
      company.uptime = [company.uptime, 100].min
      company.customers += rand(20..100)
      @log << "[SLO] Refined SLOs. Customer trust improving. Uptime target tightened."
    else
      company.slo_defined = true
      company.uptime += rand(0.2..0.5)
      company.uptime = [company.uptime, 100].min
      company.customers += rand(50..200)
      @log << "[SLO] SLOs defined! Customers can now see you actually care about reliability. Revolutionary."
    end
  end

  def do_chaos_engineering
    if company.observability_level < 2
      @log << "[CHAOS] Ran chaos experiment. Broke everything. Couldn't figure out why because observability is at level #{company.observability_level}. Invest in monitoring first, yeah?"
      company.tech_debt += rand(1.0..3.0)
      return
    end

    company.chaos_engineering = true
    debt_found = rand(2.0..8.0)
    company.tech_debt = [company.tech_debt - debt_found, 0].max
    company.uptime += rand(0.1..0.4)
    company.uptime = [company.uptime, 100].min

    @log << "[CHAOS] Chaos engineering found #{debt_found.round(1)}% hidden debt. Fixed it before it fixed you at 3am."
  end

  def do_team_building
    morale_boost = rand(5.0..15.0)
    company.morale = [company.morale + morale_boost, 100].min
    company.oncall_burden = [company.oncall_burden - 3, 0].max

    activities = [
      "Escape room. The team escaped in 45 minutes. Dave still hasn't found the key.",
      "Retro with actual action items. Historic first.",
      "Pizza Friday. The vegans got real pizza this time.",
      "Board game night. Someone flipped the Settlers of Catan board.",
      "Karaoke night. The CTO did Bohemian Rhapsody. Twice.",
      "Hackathon! Three projects started. Zero will ship. Classic.",
      "Team lunch at that place everyone pretends to like.",
      "Virtual escape room. Two people were on mute the entire time."
    ]

    @log << "[TEAM] #{activities.sample} Morale +#{morale_boost.round(1)}%."
  end

  def do_fundraise
    if company.revenue < 10_000
      @log << "[VC] Pitched to investors. They asked about revenue. Meeting ended quickly."
      company.action_points += 1
      return
    end

    multiplier = rand(10..30)
    raise_amount = company.revenue * multiplier
    company.budget += raise_amount
    company.feature_pressure += 3

    @log << "[VC] Raised #{format_money(raise_amount)}! Investors celebrated. Then asked when you're shipping AI features."
  end

  # ─── Events ──────────────────────────────────────────

  def generate_events
    events = []
    events << traffic_spike if rand < traffic_spike_chance
    events << production_outage if rand < outage_chance
    events << engineer_quits if rand < quit_chance
    events << security_vuln if rand < 0.12
    events << competitor_launch if rand < 0.10
    events << board_meeting if company.feature_pressure > 0 || rand < 0.15
    events << cloud_incident if rand < 0.08
    events << viral_hn_post if rand < 0.07
    events << compliance_requirement if rand < 0.06

    events << quiet_sprint if events.empty?
    events.compact
  end

  def traffic_spike_chance
    base = 0.15
    base += 0.1 if company.customers > 10_000
    base += 0.1 if company.customers > 50_000
    base
  end

  def outage_chance
    base = 0.05
    base += company.tech_debt / 200.0
    base += 0.1 if company.observability_level < 2
    base -= 0.05 if company.chaos_engineering
    base.clamp(0.05, 0.5)
  end

  def quit_chance
    base = 0.05
    base += (100 - company.morale) / 200.0
    base += company.oncall_burden / 200.0
    base -= 0.05 if company.morale > 80
    base.clamp(0.02, 0.4)
  end

  def traffic_spike
    if company.tech_debt < 30 && company.observability_level >= 3
      revenue_bump = company.revenue * rand(0.1..0.3)
      customer_bump = rand(100..500)
      company.revenue += revenue_bump
      company.customers += customer_bump
      { type: 'success', icon: '📈',
        message: "[INFO] Traffic spike! Your infrastructure held like a champ. Revenue +#{format_money(revenue_bump)}, +#{customer_bump} new customers." }
    else
      uptime_hit = rand(0.5..2.0)
      company.uptime = [company.uptime - uptime_hit, 80].max
      customer_loss = rand(10..100)
      company.customers = [company.customers - customer_loss, 0].max
      { type: 'danger', icon: '🔥',
        message: "[CRIT] Traffic spike hit and your infrastructure crumbled like a digestive biscuit in tea. Uptime -#{uptime_hit.round(2)}%, -#{customer_loss} customers." }
    end
  end

  def production_outage
    severity = (company.tech_debt / 25.0).ceil.clamp(1, 4)
    uptime_hit = severity * rand(0.3..1.0)
    revenue_hit = company.revenue * severity * rand(0.02..0.08)
    morale_hit = severity * rand(2.0..5.0)
    customer_loss = severity * rand(5..30)

    recovery_bonus = company.observability_level * 0.1
    uptime_hit = [uptime_hit - recovery_bonus, 0.1].max

    company.uptime = [company.uptime - uptime_hit, 80].max
    company.revenue = [company.revenue - revenue_hit, 0].max
    company.morale = [company.morale - morale_hit, 0].max
    company.customers = [company.customers - customer_loss, 0].max
    company.oncall_burden += severity * 3

    outage_messages = [
      "[P#{severity}] Production outage! #{outage_flavor(severity)} MTTR: #{mttr_for_level(company.observability_level)}.",
      "[P#{severity}] Incident declared. #{outage_cause}. The postmortem will be \"blameless\" (sure it will).",
      "[P#{severity}] Everything's on fire. #{outage_cause}. Status page updated to 'Investigating' (it's been 4 hours)."
    ]

    { type: 'danger', icon: '🚨',
      message: outage_messages.sample + " Uptime -#{uptime_hit.round(2)}%, revenue -#{format_money(revenue_hit)}." }
  end

  def engineer_quits
    return nil if company.headcount <= 1

    company.headcount -= 1
    company.morale -= rand(3.0..8.0)
    company.morale = [company.morale, 0].max
    company.oncall_burden += 5

    quit_messages = [
      "[WARN] Engineer handed in their resignation. Their Slack status reads 'Gone fishing. Forever.'",
      "[WARN] Senior engineer quit. Said something about 'work-life balance' and 'not being paged at 3am on Christmas.'",
      "[WARN] Engineer left for a FAANG. Can't compete with that RSU package, honestly.",
      "[WARN] Your lead SRE rage-quit after being paged #{rand(20..50)} times this sprint. Last commit message: 'I am free.'",
      "[WARN] An engineer left. Their exit interview was just a link to their LinkedIn profile and a middle finger emoji.",
      "[WARN] Developer departed. They mass-deleted their Slack messages. Ominous.",
      "[WARN] Engineer quit to 'start a podcast about engineering culture.' You've created a monster."
    ]

    { type: 'warning', icon: '👋',
      message: "#{quit_messages.sample} Headcount → #{company.headcount}." }
  end

  def security_vuln
    if company.observability_level >= 4
      company.tech_debt += rand(1.0..3.0)
      { type: 'warning', icon: '🔒',
        message: "[WARN] Security vulnerability detected in a dependency. Good news: your observability caught it early. Patched with minimal drama." }
    else
      uptime_hit = rand(0.2..1.0)
      budget_hit = rand(10_000..100_000)
      company.uptime = [company.uptime - uptime_hit, 80].max
      company.budget -= budget_hit
      company.tech_debt += rand(3.0..8.0)
      { type: 'danger', icon: '🔓',
        message: "[CRIT] Security vulnerability exploited! Cost #{format_money(budget_hit)} to remediate. The CISO is not returning your calls." }
    end
  end

  def competitor_launch
    company.feature_pressure += 2
    customer_loss = rand(10..100)
    company.customers = [company.customers - customer_loss, 0].max

    competitors = [
      "CompetitorCorp just launched a feature you've had on the roadmap for 6 months",
      "A YC startup just demo'd exactly what you're building, but with AI",
      "AWS just announced a managed version of your product. Classic",
      "Some kid on GitHub built your core product as a weekend project",
      "A competitor raised $100M. Their product is worse but their marketing is terrifying"
    ]

    { type: 'warning', icon: '⚔️',
      message: "[INTEL] #{competitors.sample}. -#{customer_loss} customers. Board wants answers." }
  end

  def board_meeting
    if company.feature_pressure > 5
      company.morale -= rand(5.0..10.0)
      company.morale = [company.morale, 0].max
      { type: 'danger', icon: '📋',
        message: "[BOARD] Emergency board meeting. Investors want features NOW. \"Technical debt? What's that? Ship the thing.\" Morale tanks." }
    elsif company.revenue > 1_000_000
      company.feature_pressure = [company.feature_pressure - 1, 0].max
      { type: 'success', icon: '📋',
        message: "[BOARD] Board meeting went well! Revenue numbers impressed. You bought yourself another quarter. Enjoy it." }
    else
      company.feature_pressure += 1
      { type: 'warning', icon: '📋',
        message: "[BOARD] Board meeting. They smiled but their eyes said 'where's the growth?' Feature pressure increasing." }
    end
  end

  def cloud_incident
    if company.observability_level >= 5 && company.chaos_engineering
      { type: 'success', icon: '☁️',
        message: "[INFO] #{cloud_provider_name} had a regional outage. Your multi-region setup held perfectly. Smug tweets were posted." }
    else
      uptime_hit = rand(0.5..2.0)
      company.uptime = [company.uptime - uptime_hit, 80].max
      { type: 'danger', icon: '☁️',
        message: "[CRIT] #{cloud_provider_name} #{cloud_failure}. Your status page says 'Not our fault' but customers don't care. Uptime -#{uptime_hit.round(2)}%." }
    end
  end

  def viral_hn_post
    revenue_bump = company.revenue * rand(0.2..0.5)
    customer_bump = rand(200..2000)
    company.revenue += revenue_bump
    company.customers += customer_bump

    if company.tech_debt > 50
      uptime_hit = rand(0.5..1.5)
      company.uptime = [company.uptime - uptime_hit, 80].max
      { type: 'warning', icon: '🔥',
        message: "[HN] Your product went viral on Hacker News! Great for revenue (+#{format_money(revenue_bump)}), bad for your servers. Top comment: 'This is just a wrapper around #{%w[Redis Postgres curl].sample}.'" }
    else
      { type: 'success', icon: '🔥',
        message: "[HN] Viral HN post! +#{customer_bump} customers, +#{format_money(revenue_bump)} revenue. Top comment: 'Neat, but does it run on Kubernetes?' It does now." }
    end
  end

  def compliance_requirement
    cost = rand(50_000..200_000)
    company.budget -= cost
    company.tech_debt += rand(2.0..5.0)

    regs = ['SOC 2', 'GDPR', 'HIPAA', 'PCI DSS', 'ISO 27001']
    { type: 'warning', icon: '📜',
      message: "[COMPLIANCE] #{regs.sample} audit incoming. Cost #{format_money(cost)}. An auditor just asked why your password policy is 'password123'. Fair question." }
  end

  def quiet_sprint
    company.morale += rand(1.0..3.0)
    company.morale = [company.morale, 100].min
    { type: 'info', icon: '😌',
      message: "[INFO] Quiet sprint. No incidents. No drama. The on-call engineer actually slept through the night. Unprecedented." }
  end

  # ─── Passive Effects ─────────────────────────────────

  def apply_passive_effects
    # Monthly burn
    salary_burn = company.headcount * rand(8_000..12_000)
    infra_cost = company.customers * rand(0.5..2.0)
    company.budget -= (salary_burn + infra_cost)

    # Revenue growth (organic)
    if company.customers > 0
      organic_growth = company.customers * rand(0.5..2.0) * (1 - company.tech_debt / 150.0)
      company.revenue += organic_growth
    end

    # Tech debt passive effects
    if company.tech_debt > 70
      company.uptime -= rand(0.1..0.5)
      company.morale -= rand(1.0..3.0)
    end

    # Uptime natural drift
    if company.slo_defined
      company.uptime += rand(0.05..0.15)
    end
    company.uptime = company.uptime.clamp(80, 100)
    company.morale = company.morale.clamp(0, 100)
    company.tech_debt = company.tech_debt.clamp(0, 100)

    # Feature pressure decay
    company.feature_pressure = [company.feature_pressure - 1, 0].max

    # On-call burden natural increase
    company.oncall_burden += rand(1.0..3.0) if company.headcount < 10
    company.oncall_burden = company.oncall_burden.clamp(0, 100)
  end

  # ─── Game Over Checks ───────────────────────────────

  def check_game_over_conditions
    # Check IPO first (win condition)
    if company.ipo_ready?
      company.game_over = true
      company.game_over_reason = 'ipo'
      record_score(true)
      return
    end

    # Uptime streak check
    if company.uptime < 95
      company.low_uptime_streak += 1
    else
      company.low_uptime_streak = 0
    end

    if company.low_uptime_streak >= 3
      company.game_over = true
      company.game_over_reason = 'uptime'
      record_score(false)
    elsif company.budget <= 0
      company.game_over = true
      company.game_over_reason = 'bankrupt'
      record_score(false)
    elsif company.morale <= 0
      company.game_over = true
      company.game_over_reason = 'morale'
      record_score(false)
    elsif company.headcount <= 0
      company.game_over = true
      company.game_over_reason = 'no_team'
      record_score(false)
    end
  end

  def calculate_score
    company.score = (
      company.revenue / 100.0 +
      company.uptime * 100 +
      company.customers +
      company.headcount * 50 +
      (100 - company.tech_debt) * 10 +
      company.morale * 5 -
      company.turn * 10
    ).round
  end

  def record_score(won)
    Score.create!(
      company_name: company.name,
      scenario: company.scenario,
      turns_to_completion: company.turn,
      final_score: company.score,
      final_revenue: company.revenue,
      final_uptime: company.uptime,
      final_headcount: company.headcount,
      won: won,
      completed_at: Time.current
    )
  end

  # ─── Flavor Text ─────────────────────────────────────

  def format_money(amount)
    if amount >= 1_000_000
      "$#{(amount / 1_000_000.0).round(2)}M"
    elsif amount >= 1_000
      "$#{(amount / 1_000.0).round(1)}K"
    else
      "$#{amount.round(0)}"
    end
  end

  def observability_flavor(level)
    flavors = {
      1 => 'basic logs (console.log everywhere)',
      2 => 'structured logging (fancy)',
      3 => 'metrics + dashboards (Grafana shrine installed)',
      4 => 'distributed tracing (you can follow a request through the void)',
      5 => 'full observability stack (you see the Matrix)',
      6 => 'predictive alerting (alerts before incidents)',
      7 => 'AIOps integration (the robots are helping)',
      8 => 'custom SLI tracking (nerd level: expert)',
      9 => 'chaos-aware observability (inception-level monitoring)',
      10 => 'omniscience (you can see production dreams)'
    }
    flavors[level] || 'enlightenment'
  end

  def outage_flavor(severity)
    case severity
    when 1 then "Minor blip. Only the most paranoid customers noticed."
    when 2 then "Significant degradation. Twitter is asking questions."
    when 3 then "Major outage. The CEO is calling. Don't answer."
    when 4 then "Total catastrophe. Someone is updating their resume mid-incident."
    end
  end

  def mttr_for_level(obs_level)
    times = ['6 hours (we guessed)', '4 hours', '2 hours', '45 minutes',
             '20 minutes', '12 minutes', '8 minutes', '5 minutes',
             '3 minutes', '90 seconds', '47 seconds (new record)']
    times[[obs_level, 10].min]
  end

  def outage_cause
    [
      "A config change that 'definitely wasn't supposed to go to prod'",
      "Someone ran DROP TABLE in the wrong terminal",
      "The intern pushed to main. Again",
      "Memory leak that's been there since 2021",
      "Certificate expired. No one set a reminder",
      "DNS. It's always DNS",
      "A dependency updated and broke everything",
      "The database decided it needed a holiday",
      "Auto-scaling went the wrong way",
      "Someone's cron job went rogue"
    ].sample
  end

  def cloud_provider_name
    ['AWS', 'GCP', 'Azure', 'Cloudflare', 'Heroku'].sample
  end

  def cloud_failure
    [
      'had a region-wide outage',
      'lost an availability zone',
      'had a networking partition',
      'deployed a bad update to their control plane',
      'had an S3-level event (again)'
    ].sample
  end
end
