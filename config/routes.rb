Rails.application.routes.draw do
  namespace :admin do
    namespace :forest do
      namespace :shopify do
        resources :products
      end
    end
  end
end
