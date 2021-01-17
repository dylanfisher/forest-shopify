namespace :forest do
  namespace :shopify do
    desc 'Sync all Shopify storefront API endpoints.'
    task :sync => :environment do
      Forest::Shopify::SyncProductsJob.perform_now
      Forest::Shopify::SyncCollectionsJob.perform_now
    end

    desc 'Sync Shopify products and variants.'
    task :sync_products => :environment do
      Forest::Shopify::SyncProductsJob.perform_now
    end

    desc 'Sync Shopify collections.'
    task :sync_collections => :environment do
      Forest::Shopify::SyncCollectionsJob.perform_now
    end
  end
end
