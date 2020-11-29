module Forest::Shopify::Storefront::Info
  # Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Info::Query)

  Query = Forest::Shopify::Storefront::Client.parse <<-'GRAPHQL'
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
