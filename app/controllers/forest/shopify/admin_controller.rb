module Forest
  module Shopify
    class AdminController < Admin::ForestController
      helper_method :forest_shopify_domain

      def forest_shopify_domain
        @_forest_shopify_domain ||= (ENV['FOREST_SHOPIFY_DOMAIN'].presence || Rails.application.credentials[:shopify_domain])
      end
    end
  end
end
