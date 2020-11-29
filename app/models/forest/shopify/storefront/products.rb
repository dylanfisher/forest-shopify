module Forest::Shopify::Storefront::Products
  # Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Products::Query)

  Query = Forest::Shopify::Storefront::Client.parse <<-'GRAPHQL'
    query($after: String) {
      products(first: 250, after: $after) {
        pageInfo {
          hasNextPage
        }
        edges {
          cursor
          node {
            availableForSale
            createdAt
            description
            descriptionHtml
            handle
            id
            productType
            publishedAt
            title
            variants(first: 10) {
              edges {
                node {
                  available
                  availableForSale
                  compareAtPrice
                  id
                  price
                  sku
                  title
                  weight
                  weightUnit
                }
              }
            }
            images(first: 10) {
              edges {
                node {
                  altText
                  id
                  src
                }
              }
            }
            options(first: 3) {
              id
              name
              values
            }
            metafields(first: 10) {
              edges {
                cursor
                node {
                  description
                  id
                  key
                  namespace
                  value
                  valueType
                }
              }
              pageInfo {
                hasNextPage
              }
            }
            collections(first: 10) {
              edges {
                cursor
                node {
                  id
                  title
                  description
                  handle
                }
              }
              pageInfo {
                hasNextPage
              }
            }
          }
        }
      }
    }
  GRAPHQL
end
