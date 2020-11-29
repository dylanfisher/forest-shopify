namespace :forest do
  namespace :shopify do
    desc 'Sync all Shopify storefront API endpoints.'
    task :sync_all do
      # TODO: how to handle pagination
      products = Storefront::Client.query(Storefront::Products::Query)
    end
  end
end
