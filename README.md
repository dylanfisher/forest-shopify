# Forest::Shopify
Sync a Shopify store with a Rails application running Forest CMS.

## Rake tasks
Sync all Shopify storefront API endpoints. Run this in a cron job to keep your store up to date with Shopify.

`rails forest:shopify:sync_all`

## Forest CMS Resources
Forest Shopify adds the following resources to the Forest CMS dashboard.

`Forest::Shopify::Product`

`Forest::Shopify::Variant`

## GraphQL Client Syncing
Forest Shopify syncs products server-side using GitHub's `graphql-client` library. This code is namespaced
in the `Forest::Shopify::Storefront` class.

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
- Listen to webhooks to avoid potential of stale data using just a sync task via cron job
- Document frontend javascript examples of how to interact with the store via the `js-buy-sdk` library.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
