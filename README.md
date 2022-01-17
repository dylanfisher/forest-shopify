# Forest::Shopify
Sync a Shopify store with a Rails application running Forest CMS.

## Installation

```ruby
gem 'forest-shopify', git: 'https://github.com/dylanfisher/forest-shopify.git'
```

Add the following key/values to your Rails credentials file, or specify an environment variable to override.

The Shopify domain

`shopify_domain: my-app.myshopify.com` or override with `ENV['FOREST_SHOPIFY_DOMAIN']`

[The GraphQl endpoint](https://shopify.dev/concepts/about-apis/versioning#calling-an-api-version)

`shopify_graphql_endpoint: 'https://my-app.myshopify.com/api/2021-01/graphql'` or override with `ENV['FOREST_SHOPIFY_GRAPHQL_ENDPOINT']`

[Shopify Storefront Access Token](https://shopify.dev/docs/storefront-api/getting-started#private-app) (this is the
public access token used to make unathenticated public API requests - the same token used in your app's frontend JavaScript).

`shopify_storefront_access_token: abcdef123456` or override with `ENV['FOREST_SHOPIFY_STOREFRONT_ACCESS_TOKEN']`

[Shopify Webhook Secret key](https://shopify.dev/tutorials/manage-webhooks#configuring-webhooks)

`shopify_webhook_key: abcdef123456` or override with `ENV['FOREST_SHOPIFY_WEBHOOK_KEY']`

## Rake tasks
The following rake tasks should be configured to run in a cron job to periodically sync products between Shopify and your Rails app.

- `rails forest:shopify:sync` -> Sync all Shopify storefront API endpoints.
- `rails forest:shopify:sync_products` -> Sync Shopify products and variants.
- `rails forest:shopify:sync_collections` -> Sync Shopify collections.

## Forest CMS Resources
Forest Shopify adds the following resources to the Forest CMS dashboard.

- `Forest::Shopify::Product`
- `Forest::Shopify::Variant`
- `Forest::Shopify::Collection`
- `Forest::Shopify::ProductOption`

Add the Forest Shopify resources to your host app's dashboard panel:

```
<%= render 'admin/dashboard/forest_shopify_panel',
           title: 'Products',
           resources: [Forest::Shopify::Product, Forest::Shopify::Variant, Forest::Shopify::Collection] %>
```

## GraphQL Client Syncing
Forest Shopify syncs products server-side using GitHub's `graphql-client` library. This code is namespaced
in the `Forest::Shopify::Storefront` class.

When debugging issues with setting up the initial GraphQL sync, you may need to regenerate the cached schema, especially if
the initial request to sync the store is misconfigured. This file is located at `public/forest/shopify/storefront/schema.json`.

## Webhooks
Configure your application to listen for webhooks configured in Shopify that notify and update products without
waiting for the sync task to run.

In Shopify, configure the following webhook events and URLS in JSON format.

- `Product creation` -> `https://my-app.com/forest/shopify/webhooks/products/create`
- `Product update` -> `https://my-app.com/forest/shopify/webhooks/products/update`
- `Product deletion` -> `https://my-app.com/forest/shopify/webhooks/products/destroy`
- `Collection creation` -> `https://my-app.com/forest/shopify/webhooks/collections/create`
- `Collection update` -> `https://my-app.com/forest/shopify/webhooks/collections/update`
- `Collection deletion` -> `https://my-app.com/forest/shopify/webhooks/collections/destroy`

## Routes
You'll likely want to include the following routes.

```
get '/cart', to: 'cart#edit'
get '/shop', to: 'collections#show', id: 'all'
get '/products', to: redirect('/shop')
get '/collections/:collection_id/products/:id', to: 'products#show', as: 'collection_product'
get '/application.css', to: 'asset_redirects#application_css',  format: :css # This provides a static link for use in
get '/application.js', to: 'asset_redirects#application_js',  format: :js    # This provides a static link for use in

resources :collections, only: [:show]
resources :products, only: [:show]
```

## Frontend JavaScript
Suggested boilerplate for setting up your app's frontend JavaScript is [available on the wiki](https://github.com/dylanfisher/forest-shopify/wiki/Frontend-JavaScript).

## TODO
- Better logic for determining price of product with no variants; show this in the index and edit views
- Determine if discounts are reflected in the current API calls
- Analytics compatible with Shopify (Google, FB Pixel, etc.)

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
