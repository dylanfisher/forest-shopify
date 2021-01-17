module Forest::Shopify
  class SyncCollectionsJob < ApplicationJob
    queue_as :default

    def perform
      begin
        Forest::Shopify::Storefront::Collection.sync
      rescue Exception => e
        backtrace = e.backtrace.first(10).join("\n")
        logger.error { "[Forest][Error] Forest::Shopify::Storefront::Collection.sync failed\n#{e.message}\n#{backtrace}" }
      end
    end
  end
end
