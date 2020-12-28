namespace :forest do
  namespace :shopify do
    desc 'Sync all Shopify storefront API endpoints.'
    task :sync => :environment do
      begin
        Forest::Shopify::Storefront::Products.sync
      rescue Exception => e
        backtrace = e.backtrace.first(10).join("\n")
        logger.error { "[Forest][Error] Shopify product sync failed\n#{e.message}\n#{backtrace}" }
      end
    end

    private

    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
