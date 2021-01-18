module Forest::Shopify
  class SyncCollectionsJob < ApplicationJob
    queue_as :default

    def perform(shopify_id_base64: nil)
      begin
        Forest::Shopify::Storefront::Collection.sync(shopify_id_base64: shopify_id_base64)
      rescue Exception => e
        backtrace = e.backtrace.first(10).join("\n")
        logger.error { "[Forest][Error] Forest::Shopify::Storefront::Collection.sync failed\n#{e.message}\n#{backtrace}" }
      end
    end
  end
end
