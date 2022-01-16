class Forest::Shopify::CollectionPolicy < BlockRecordPolicy
  def sync?
    admin?
  end
end
