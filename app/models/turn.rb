class Turn < ApplicationRecord
  belongs_to :company

  def parsed_actions
    JSON.parse(actions_taken || '[]')
  rescue JSON::ParserError
    []
  end

  def parsed_events
    JSON.parse(events || '[]')
  rescue JSON::ParserError
    []
  end

  def parsed_metrics
    JSON.parse(metrics_snapshot || '{}')
  rescue JSON::ParserError
    {}
  end
end
