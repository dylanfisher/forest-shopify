module Forest
  module Shopify
    module Webhooks
      class ProductsController < WebhooksController
        before_action :set_product

        def create
          # TODO: create new product
          head :ok
        end

        def update
          # TODO: update the product
          @product.touch

          head :ok
        end

        def destroy
          @product.destroy

          head :ok
        end

        private

        def set_product
          @product = Forest::Shopify::Product.find_by_shopify_id(params[:id])
        end
      end
    end
  end
end
