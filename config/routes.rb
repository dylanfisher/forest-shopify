Rails.application.routes.draw do
  namespace :admin do
    namespace :forest do
      namespace :shopify do
        resources :products, except: :show do
          collection do
            post 'sync'
          end
        end
        resources :variants
      end
    end
  end
end
