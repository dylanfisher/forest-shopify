module Forest::Shopify
  class SyncProductsJob < ApplicationJob
    queue_as :default

    def perform(shopify_id_base64: nil)
      begin
        Forest::Shopify::Storefront::Product.sync(shopify_id_base64: shopify_id_base64)
      rescue Exception => e
        backtrace = e.backtrace.first(10).join("\n")
        Rails.logger.error { "[Forest][Error] Forest::Shopify::Storefront::Product.sync failed\n#{e.message}\n#{backtrace}" }
      end
    end
  end
end
