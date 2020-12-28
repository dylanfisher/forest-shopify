module Forest
  module Shopify
    module Webhooks
      class ProductsController < WebhooksController
        def create
          # TODO: create new product
          head :ok
        end

        def update
          # TODO: update the product
          head :ok
        end

        def destroy
          # TODO: destroy the product
          head :ok
        end
      end
    end
  end
end
