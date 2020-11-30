class Forest::Shopify::Product < Forest::ApplicationRecord
  include Sluggable

  before_save :decode_shopify_id

  has_many :variants, class_name: 'Forest::Shopify::Variant', foreign_key: 'forest_shopify_product_id', dependent: :destroy

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
