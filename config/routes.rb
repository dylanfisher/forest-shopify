Rails.application.routes.draw do
  # Public
  namespace :forest do
    namespace :shopify do
      namespace :webhooks do
        # https://shopify.dev/docs/admin-api/rest/reference/events/webhook
        post 'products/create', to: 'products#create'
        post 'products/update', to: 'products#update'
        post 'products/destroy', to: 'products#destroy'
      end
    end
  end

  # Admin
  namespace :admin do
    namespace :forest do
      namespace :shopify do
        resources :collections, except: :show
        resources :products, except: :show do
          collection do
            post 'sync'
          end
        end
        resources :variants, except: :show
      end
    end
  end
end
