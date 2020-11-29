class Forest::Shopify::Product < Forest::ApplicationRecord
  include Sluggable

  def self.resource_description
    'Products are synced automatically from Shopify.'
  end

  def slug_attribute
    handle
  end
end
