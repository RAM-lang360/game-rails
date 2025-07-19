Rails.application.routes.draw do
  # メールアナウンスデバック用
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  resources :signin
  resource :session
  resources :passwords, param: :token

  # ログアウトルートを先に配置
  delete "logout", to: "sessions#destroy", as: :logout

  # 特定のlobbyルートをresources :lobbyより前に配置
  post "lobby/join", to: "lobby#join", as: :join
  get "lobby/join_room", to: "lobby#join_room", as: :join_room
  get "lobby/:id/good_ans", to: "games#good_ans", as: "good_ans_game"

  # logout_roomルートをGETとDELETEの両方に対応
  get "lobby/:id/logout_room", to: "lobby#logout_room", as: :logout_room
  delete "lobby/:id/logout_room", to: "lobby#logout_room"

  # resources :lobbyを後に配置
  resources :lobby

  # gamesルート
  post "games/:id/draw", to: "games#draw", as: :draw
  post "games/:id/post", to: "games#post", as: :post_game
  post "games/:id/show_answer", to: "games#show_answer", as: :show_answer

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "lobby#index"
end
