module Storefront::Products
  # Forest::Shopify::Storefront::Client.query(Storefront::Products::Query)

  Query = Forest::Shopify::Storefront::Client.parse <<-'GRAPHQL'
    {
      products(first: 50) {
        pageInfo {
          hasNextPage
        }
        edges {
          cursor
          node {
            id
            title
            description
            availableForSale
            images(first: 1) {
              edges {
                node {
                  id
                  originalSrc
                  transformedSrc
                }
              }
            }
          }
        }
      }
    }
  GRAPHQL
end
