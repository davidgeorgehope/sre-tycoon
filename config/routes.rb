Rails.application.routes.draw do
  root "games#index"

  resources :games, only: [:index, :new, :create, :show] do
    member do
      post :action
      post :end_turn
    end
    collection do
      get :leaderboard
    end
  end
end
