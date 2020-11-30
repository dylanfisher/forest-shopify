class Forest::Shopify::Product < Forest::ApplicationRecord
  include Sluggable

  before_save :decode_shopify_id

  scope :available_for_sale, -> { where(available_for_sale: true) }

  def self.resource_description
    'Products are synced automatically from Shopify.'
  end

  def slug_attribute
    handle
  end

  private

  def decode_shopify_id
    self.shopify_id = Base64.decode64(shopify_id_base64).split('/').last if shopify_id_base64_changed?
  end
end
