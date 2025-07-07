PinFlags::Engine.routes.draw do
  namespace :feature_tags do
    resources :imports, only: %i[create]
    resources :exports, only: %i[index]
  end

  resources :feature_tags, except: %i[edit] do
    resources :feature_subscriptions, only: %i[new create destroy], module: :feature_tags
  end

  root "feature_tags#index"
end
