namespace :forest do
  namespace :shopify do
    desc 'Sync all Shopify storefront API endpoints.'
    task :sync => :environment do
      sync_products
      sync_collections
    end

    desc 'Sync Shopify products and variants.'
    task :sync_products => :environment do
      sync_products
    end

    desc 'Sync Shopify collections.'
    task :sync_collections => :environment do
      sync_collections
    end

    def sync
      sync_products
      sync_collections
    end

    def sync_products
      begin
        Forest::Shopify::Storefront::Product.sync
      rescue Exception => e
        backtrace = e.backtrace.first(10).join("\n")
        logger.error { "[Forest][Error] Forest::Shopify::Storefront::Product.sync failed\n#{e.message}\n#{backtrace}" }
      end
    end

    def sync_collections
      begin
        Forest::Shopify::Storefront::Collection.sync
      rescue Exception => e
        backtrace = e.backtrace.first(10).join("\n")
        logger.error { "[Forest][Error] Forest::Shopify::Storefront::Collection.sync failed\n#{e.message}\n#{backtrace}" }
      end
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
