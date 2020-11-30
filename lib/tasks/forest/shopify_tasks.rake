namespace :forest do
  namespace :shopify do
    desc 'Sync all Shopify storefront API endpoints.'
    task :sync_all => :environment do
      Forest::Shopify::Storefront::Products.sync
    end
  end
end
