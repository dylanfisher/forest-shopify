module Forest
  module Shopify
    class WebhooksController < ApplicationController
      skip_before_action :verify_authenticity_token

      before_action :verify_webhook

      SHARED_SECRET = Rails.application.credentials[:shopify_webhook_key]

      private

      # Compare the computed HMAC digest based on the shared secret and the request contents
      # to the reported HMAC in the headers
      #
      # https://shopify.dev/tutorials/manage-webhooks#verify-webhook
      def verify_webhook
        data = request.body.read
        hmac_header = request.env['HTTP_X_SHOPIFY_HMAC_SHA256'].to_s

        calculated_hmac = Base64.strict_encode64(OpenSSL::HMAC.digest('sha256', SHARED_SECRET, data))
        verified = ActiveSupport::SecurityUtils.secure_compare(calculated_hmac, hmac_header)

        unless verified
          # Unverified requests return early
          head :bad_request
        end
      end
    end
  end
end
