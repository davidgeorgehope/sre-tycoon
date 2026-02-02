class GamesController < ApplicationController
  before_action :set_company, only: [:show, :action, :end_turn]

  def index
    @recent_games = Company.where(game_over: false).order(updated_at: :desc).limit(5)
  end

  def new
  end

  def create
    scenario = params[:scenario] || 'startup'
    scenario_data = Company::SCENARIOS[scenario]

    unless scenario_data
      redirect_to new_game_path, alert: "Invalid scenario"
      return
    end

    company = Company.create!(
      name: params[:company_name].presence || "Untitled Corp",
      scenario: scenario,
      budget: scenario_data[:budget],
      headcount: scenario_data[:headcount],
      tech_debt: scenario_data[:tech_debt],
      morale: scenario_data[:morale],
      uptime: scenario_data[:uptime],
      revenue: scenario_data[:revenue],
      customers: scenario_data[:customers],
      observability_level: scenario_data[:observability_level],
      action_points: 3
    )

    redirect_to game_path(company)
  end

  def show
    @engine = GameEngine.new(@company)
    @actions = GameEngine::ACTIONS
    @turns = @company.turns.order(turn_number: :desc).limit(5)
    @last_turn = @turns.first
  end

  def action
    engine = GameEngine.new(@company)
    result = engine.perform_action(params[:action_type])

    if result[:error]
      redirect_to game_path(@company), alert: result[:error]
    else
      redirect_to game_path(@company), notice: result[:message]
    end
  end

  def end_turn
    engine = GameEngine.new(@company)
    result = engine.end_turn

    if @company.game_over?
      redirect_to game_path(@company), notice: "Game Over!"
    else
      redirect_to game_path(@company), notice: "Sprint #{@company.turn - 1} complete!"
    end
  end

  def leaderboard
    @winners = Score.winners.limit(20)
    @recent = Score.recent
    @shame = Score.hall_of_shame.limit(10)
  end

  private

  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Game not found"
  end
end
