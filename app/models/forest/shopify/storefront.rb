require 'graphql/client'
require 'graphql/client/http'

# https://github.com/github/graphql-client
class Forest::Shopify::Storefront
  # Configure GraphQL endpoint using the basic HTTP network adapter.
  HTTP = GraphQL::Client::HTTP.new(ENV['FOREST_SHOPIFY_GRAPHQL_ENDPOINT'].presence || Rails.application.credentials[:shopify_graphql_endpoint]) do
    def headers(context)
      # Optionally set any HTTP headers
      {
        'X-Shopify-Storefront-Access-Token': (ENV['FOREST_SHOPIFY_STOREFRONT_ACCESS_TOKEN'].presence || Rails.application.credentials[:shopify_storefront_access_token]),
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
  #   GraphQL::Client.dump_schema(Forest::Shopify::Storefront::HTTP, 'path/to/schema.json')
  #
  # Schema = GraphQL::Client.load_schema('path/to/schema.json')

  schema_dir = Rails.root.join('public', 'forest', 'shopify', 'storefront').to_s
  schema_file = "#{schema_dir}/schema.json"

  if !File.exist?(schema_file) || (Time.current - File.mtime(schema_file) > 1.week.seconds)
    FileUtils.mkdir_p(schema_dir)
    FileUtils.touch(schema_file)
    GraphQL::Client.dump_schema(Forest::Shopify::Storefront::HTTP, schema_file)
  end

  Schema = GraphQL::Client.load_schema(schema_file)

  Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

  def self.create_images(images:, forest_shopify_record:)
    images = Array(images)

    record_cache = Forest::Shopify::Image.includes(:media_item).where({
      forest_shopify_record_id: forest_shopify_record.id,
      forest_shopify_record_type: forest_shopify_record.class.name,
      shopify_id_base64: images.collect(&:id)
    })

    images.each_with_index do |image, index|
      forest_shopify_image = record_cache.find { |r|
        r.forest_shopify_record_id == forest_shopify_record.id &&
        r.forest_shopify_record_type == forest_shopify_record.class.name &&
        r.shopify_id_base64 == image.id
      }.presence || Forest::Shopify::Image.find_or_initialize_by({
        forest_shopify_record_id: forest_shopify_record.id,
        forest_shopify_record_type: forest_shopify_record.class.name,
        shopify_id_base64: image.id
      })

      title = URI.parse(image.src).path.split('/').last

      forest_shopify_image.assign_attributes({
        alt_text: image.alt_text,
        src: image.src,
        title: title
      })

      has_blank_media_item = forest_shopify_image.media_item.blank?

      if has_blank_media_item
        # Parse the image's filename from the image source
        media_item = MediaItem.new({
          title: title,
          alternative_text: image.alt_text,
          media_item_status: 'hidden'
        })

        media_item.attachment = uploader.upload(URI.open(image.src))
        forest_shopify_image.media_item = media_item
        media_item.save!
      end

      forest_shopify_image.save! if (forest_shopify_image.changed? || has_blank_media_item)
    end
  end

  def self.uploader
    @uploader ||= FileUploader.new(:cache)
  end
end
