Rails.application.routes.draw do
  resources :addresses do
    get :autocomplete, on: :collection
    post :autocomplete, on: :collection
  end
end
