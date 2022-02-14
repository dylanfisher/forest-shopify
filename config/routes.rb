Rails.application.routes.draw do
  # Webhooks
  namespace :forest do
    namespace :shopify do
      namespace :webhooks do
        # https://shopify.dev/docs/admin-api/rest/reference/events/webhook
        post 'products/create', to: 'products#create'
        post 'products/update', to: 'products#update'
        post 'products/destroy', to: 'products#destroy'

        post 'collections/create', to: 'collections#create'
        post 'collections/update', to: 'collections#update'
        post 'collections/destroy', to: 'collections#destroy'
      end
    end
  end

  # Admin
  namespace :admin do
    namespace :forest do
      namespace :shopify do
        resources :collections, except: [:show, :new] do
          post 'sync', on: :collection
        end
        resources :products, except: [:show, :new] do
          post 'sync', on: :collection
        end
        resources :product_tags, except: [:show, :new]
        resources :variants, except: [:show, :new]
      end
    end
  end
end
