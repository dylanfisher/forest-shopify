module Forest
  module Shopify
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true

      before_save :decode_shopify_id

      private

      def decode_shopify_id
        return unless respond_to?(:shopify_id_base64)

        self.shopify_id = Base64.decode64(shopify_id_base64).split('/').last if shopify_id_base64_changed?
      end
    end
  end
end
