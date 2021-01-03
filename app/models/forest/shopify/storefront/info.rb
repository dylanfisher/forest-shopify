class Forest::Shopify::Storefront::Info < Forest::Shopify::Storefront
  # Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Info::Query)

  Query = Client.parse <<-'GRAPHQL'
    {
      shop {
        name
        primaryDomain {
          url
          host
        }
      }
    }
  GRAPHQL
end
