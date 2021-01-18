module Forest
  module Shopify
    module Webhooks
      class CollectionsController < WebhooksController
        before_action :set_shopify_id_base64, only: [:create, :update]
        before_action :set_collection, only: [:updated, :destroy]

        def create
          Forest::Shopify::SyncCollectionsJob.perform_later(shopify_id_base64: @shopify_id_base64)

          head :ok
        end

        def update
          Forest::Shopify::SyncCollectionsJob.perform_later(shopify_id_base64: @shopify_id_base64)

          head :ok
        end

        def destroy
          @collection.destroy if @collection.present?

          head :ok
        end

        private

        def set_collection
          @collection = Forest::Shopify::Collection.find_by_shopify_id(params[:id])
        end

        def set_shopify_id_base64
          @shopify_id_base64 = Base64.encode64(params[:admin_graphql_api_id]).squish
        end
      end
    end
  end
end
