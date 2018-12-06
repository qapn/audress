Rails.application.routes.draw do
  resources :addresses do
    post :autocomplete, on: :collection
  end
end
