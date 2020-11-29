require 'graphql/client'
require 'graphql/client/http'

# https://github.com/github/graphql-client
class Forest::Shopify::Storefront
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new(Rails.application.credentials[:shopify_graphql_endpoint]) do
    def headers(context)
      # Optionally set any HTTP headers
      {
        'X-Shopify-Storefront-Access-Token': Rails.application.credentials[:shopify_storefront_access_token],
        'Accept': 'application/json'
      }
    end
  end

  # Fetch latest schema on init, this will make a network request
  #
  # Schema = GraphQL::Client.load_schema(HTTP)

  # However, it's smart to dump this to a JSON file and load from disk
  #
  # Run it from a script or rake task
  #   GraphQL::Client.dump_schema(Storefront::HTTP, 'path/to/schema.json')
  #
  # Schema = GraphQL::Client.load_schema('path/to/schema.json')

  schema_path = Rails.root.join('public', 'storefront', 'schema.json').to_s

  if !File.exist?(schema_path) || (Time.current - File.mtime(schema_path) > 1.week.seconds)
    FileUtils.touch(schema_path)
    GraphQL::Client.dump_schema(Storefront::HTTP, schema_path)
  end

  Schema = GraphQL::Client.load_schema(schema_path)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)
end
