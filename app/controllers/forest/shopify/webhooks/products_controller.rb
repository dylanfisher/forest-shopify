module Forest
  module Shopify
    module Webhooks
      class ProductsController < WebhooksController
        before_action :set_shopify_id_base64, only: [:create, :update]
        before_action :set_product, only: [:updated, :destroy]

        def create
          Forest::Shopify::SyncProductsJob.perform_later(shopify_id_base64: @shopify_id_base64)

          head :ok
        end

        def update
          Forest::Shopify::SyncProductsJob.perform_later(shopify_id_base64: @shopify_id_base64)

          head :ok
        end

        def destroy
          @product.destroy if @product.present?

          head :ok
        end

        private

        def set_product
          @product = Forest::Shopify::Product.find_by_shopify_id(params[:id])
        end

        def set_shopify_id_base64
          @shopify_id_base64 = Base64.encode64(params[:admin_graphql_api_id]).squish
        end
      end
    end
  end
end
