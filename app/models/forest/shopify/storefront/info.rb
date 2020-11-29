module Storefront::Info
  # Forest::Shopify::Storefront::Client.query(Storefront::Info::Query)

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
