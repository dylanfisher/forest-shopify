Rails.application.routes.draw do
  namespace :admin do
    namespace :forest do
      namespace :shopify do
        resources :products do
          collection do
            post 'sync'
          end
        end
      end
    end
  end
end
