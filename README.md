# Forest::Shopify
Sync a Shopify store with a Rails application running Forest CMS.

## Installation
Add the following key/values to your Rails credentials file.

[The GraphQl endpoint](https://shopify.dev/concepts/about-apis/versioning#calling-an-api-version)

`shopify_graphql_endpoint: 'https://my-app.myshopify.com/api/2021-01/graphql'`

[Shopify Storefront Access Token](https://shopify.dev/docs/storefront-api/getting-started#private-app) (this is the
public access token used to make unathenticated public API requests - the same token used in your app's frontend JavaScript).

`shopify_storefront_access_token: abcdef123456`

[Shopify Webhook Secret key](https://shopify.dev/tutorials/manage-webhooks#configuring-webhooks)

`shopify_webhook_key: abcdef123456`


## Rake tasks
Sync all Shopify storefront API endpoints. Run this in a cron job to keep your store up to date with Shopify.

`rails forest:shopify:sync`

## Forest CMS Resources
Forest Shopify adds the following resources to the Forest CMS dashboard.

`Forest::Shopify::Product`

`Forest::Shopify::Variant`

Add the Forest Shopify resources to your host app's dashboard panel:

```
<%= render 'admin/dashboard/forest_shopify_panel',
           title: 'Products',
           resources: [Forest::Shopify::Product, Forest::Shopify::Variant, Forest::Shopify::Collection] %>
```

## GraphQL Client Syncing
Forest Shopify syncs products server-side using GitHub's `graphql-client` library. This code is namespaced
in the `Forest::Shopify::Storefront` class.

## Webhooks
Configure your application to listen for webhooks configured in Shopify that notify and update products without
waiting for the sync task to run.

In Shopify, configure the following webhook events and URLS in JSON format.

- `Product creation` -> `https://my-app.com/forest/shopify/webhooks/products/create`
- `Product update` -> `https://my-app.com/forest/shopify/webhooks/products/update`
- `Product deletion` -> `https://my-app.com/forest/shopify/webhooks/products/destroy`

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'forest-shopify'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install forest-shopify
```

## TODO
- Add additional sync and webhooks for the following resources
  - Product Collections
- Better logic for determining price of product with no variants; show this in the index and edit views
- Determine if discounts are reflected in the current API calls
- Listen to webhooks to avoid potential of stale data using just a sync task via cron job
- Document frontend javascript examples of how to interact with the store via the `js-buy-sdk` library.
- Analytics compatible with Shopify (Google, FB Pixel, etc.)
- Missing product fields (double check these exists in graphql request first)
    - status
- Missing variant fields (double check these exists in graphql request first)
    - position
    - option1
    - option2
    - option3

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
