# SRE Tycoon 🎮

**A turn-based infrastructure strategy game where you play as a VP of Engineering trying to take your company from scrappy startup to IPO — without burning out your team, tanking uptime, or going bankrupt.**

Built with Rails 8. Runs in the browser. No JavaScript frameworks were harmed in the making of this game.

> *"It's not a bug, it's an unplanned feature."*

## 🕹️ What Is This?

SRE Tycoon is a browser-based strategy game that simulates the joys and horrors of running an engineering organization. Each turn represents a two-week sprint where you spend action points on decisions like shipping features, paying down tech debt, hiring engineers, or investing in observability.

Random events keep things interesting — production outages at 3am, engineers rage-quitting, Hacker News traffic spikes, security vulnerabilities, compliance audits, and the ever-present board asking "when are we shipping AI features?"

**Win condition:** Take your company to IPO (ARR > $10M, uptime > 99.9%, team > 50 engineers).

**Lose conditions:** Go bankrupt, let morale hit zero, lose your entire team, or let uptime stay below 95% for three consecutive sprints.

## 🎯 Features

- **3 starting scenarios** with different difficulty levels:
  - 🚀 **Bootstrapped Startup** — 3 engineers, $500K, a dream
  - 💰 **Series A Rocket Ship** — 15 engineers, $5M, VCs want unicorn status
  - 🏢 **Enterprise Legacy Beast** — 200 engineers, $50M, 40% tech debt, the monolith has its own gravitational field

- **8 strategic actions** per sprint:
  - Ship Features, Pay Down Tech Debt, Invest in Observability, Hire Engineers, Define SLOs, Chaos Engineering, Team Building, Fundraise

- **Dynamic event system** — traffic spikes, outages, engineer departures, security vulns, competitor launches, board meetings, cloud provider incidents, viral HN posts, compliance audits, and the rare quiet sprint

- **10 observability levels** — from "console.log everywhere" to "omniscience (you can see production dreams)"

- **Leaderboard** with Hall of Fame (successful IPOs) and Hall of Shame (spectacular failures)

- **Terminal-aesthetic UI** with CRT scanline effects, monospace fonts, and green-on-black everything

## 🛠️ Tech Stack

- **Ruby on Rails 8.1** — server-rendered HTML, no SPA nonsense
- **SQLite** — because not everything needs Postgres
- **Puma** — web server
- **Propshaft** — asset pipeline
- **Importmap** — ES modules without a bundler
- **Source Code Pro** — the only acceptable monospace font

Zero JavaScript frameworks. The entire frontend is ERB templates with a bit of vanilla JS for scenario selection. The way the web was meant to be.

## 🚀 Running Locally

### Prerequisites

- Ruby 3.2.3+
- Bundler
- SQLite3

### Setup

```bash
git clone https://github.com/davidgeorgehope/sre-tycoon.git
cd sre-tycoon
bundle install
rails db:create db:migrate
rails server
```

Then open [http://localhost:3000](http://localhost:3000) and start managing.

### Environment

No environment variables needed. No API keys. No external services. It's just Rails and SQLite. Refreshing, isn't it?

## 📁 Project Structure

```
app/
├── controllers/
│   └── games_controller.rb    # Game lifecycle (new, create, show, action, end_turn)
├── models/
│   ├── company.rb             # Company state, scenarios, win conditions
│   ├── score.rb               # Leaderboard entries
│   └── turn.rb                # Sprint history and metrics snapshots
├── services/
│   └── game_engine.rb         # All game logic — actions, events, scoring
└── views/
    └── games/
        ├── index.html.erb     # Home — active games
        ├── new.html.erb       # Scenario selection
        ├── show.html.erb      # Main game dashboard
        └── leaderboard.html.erb
```

## 🎲 How the Game Works

Each sprint you get **3-5 action points** (scales with team size). Spend them on actions, then end the sprint. Between sprints:

1. **Random events fire** — outages, traffic spikes, departures, etc. Your observability level, tech debt, and chaos engineering investments affect probabilities.
2. **Passive effects apply** — salary burn, infrastructure costs, organic revenue growth, tech debt degradation.
3. **Game over checks run** — bankruptcy, morale collapse, team dissolution, uptime failures, or... IPO! 🎉

The tension is real: ship features to grow revenue (but accumulate tech debt), or invest in reliability (but risk the board's patience). Hire to scale, but burn budget. Fundraise for cash, but now VCs want 10x growth.

## 🏆 Scoring

Your score is a composite of:
- Revenue (÷100)
- Uptime (×100)
- Customer count
- Team size (×50)
- Low tech debt bonus ((100 - debt) × 10)
- Morale (×5)
- Sprint penalty (−10 per turn)

Fewer sprints to IPO = higher score. Leaderboard tracks both winners and the Hall of Shame.

## 📜 License

Do whatever you want with it. Ship it. Fork it. Run it at your company offsite to traumatize your engineering managers.

---

*Built by [David George Hope](https://github.com/davidgeorgehope) — because managing infrastructure should at least be fun in a game.*
