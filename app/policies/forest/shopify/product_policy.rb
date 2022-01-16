class Forest::Shopify::ProductPolicy < BlockRecordPolicy
  def sync?
    admin?
  end
end
