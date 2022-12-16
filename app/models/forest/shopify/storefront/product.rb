class Forest::Shopify::Storefront::Product < Forest::Shopify::Storefront
  # Forest::Shopify::Storefront::Client.query(Forest::Shopify::Storefront::Product::Query)
  # Forest::Shopify::Storefront::Product.sync

  LAST_SYNC_SETTING_SLUG = 'forest_shopify_product_last_sync'

  if Forest::Shopify::Product::METAFIELD_IDENTIFIERS.present?
    METAFIELDS_NODE = <<-"GRAPHQL"
      metafields(identifiers: #{Forest::Shopify::Product::METAFIELD_IDENTIFIERS}) {
      key
      value
    }
    GRAPHQL
  else
    METAFIELDS_NODE = nil
  end

  PRODUCT_NODE = <<-"GRAPHQL"
    {
      availableForSale
      createdAt
      description
      descriptionHtml
      handle
      id
      productType
      publishedAt
      tags
      title
      #{METAFIELDS_NODE}
      variants(first: 250) {
        edges {
          cursor
          node {
            availableForSale
            compareAtPriceV2 {
              amount
            }
            id
            priceV2 {
              amount
            }
            sku
            title
            weight
            weightUnit
            image {
              altText
              id
              src
            }
            selectedOptions {
              name
              value
            }
          }
        }
        pageInfo {
          hasNextPage
        }
      }
      images(first: 250) {
        edges {
          node {
            altText
            id
            src
          }
        }
        pageInfo {
          hasNextPage
        }
      }
      media(first: 250) {
        edges {
          node {
            mediaContentType
            ... MediaFieldsByType
          }
        }
      }
      options(first: 250) {
        id
        name
        values
      }
    }
  GRAPHQL

  MEDIA_FRAGMENT = <<-"GRAPHQL"
    fragment MediaFieldsByType on Media {
      ... on Video {
        id
        previewImage {
          altText
          id
          src
        }
        sources {
          url
          mimeType
          format
          height
          width
        }
      }
    }
  GRAPHQL

  Query = Client.parse <<-"GRAPHQL"
    query($after: String) {
      products(first: 250, after: $after) {
        pageInfo {
          hasNextPage
        }
        edges {
          cursor
          node #{PRODUCT_NODE}
        }
      }
    }
    #{MEDIA_FRAGMENT}
  GRAPHQL

  Query_Single = Client.parse <<-"GRAPHQL"
    query($id: ID!) {
      node(id: $id) {
        ... on Product #{PRODUCT_NODE}
      }
    }
    #{MEDIA_FRAGMENT}
  GRAPHQL

  def self.sync(shopify_id_base64: nil)
    if shopify_id_base64.present?
      response = Client.query(Query_Single, variables: { id: shopify_id_base64 })
      has_next_page = false
    else
      response = Client.query(Query)
      if response.try(:errors).present?
        Rails.logger.error { "[Forest][Error] Forest::Shopify::Storefront::Product.sync failed #{response.errors.messages.to_json}" }
        return
      else
        has_next_page = response.data.products.page_info.has_next_page
      end
    end

    matched_shopify_ids = []
    page_index = 0

    while has_next_page || page_index.zero?
      page_index += 1

      if shopify_id_base64.present?
        products = Array(response.data.node)
      else
        products = response.data.products.edges.collect(&:node)
        product_cursor = response.data.products.edges.last.try(:cursor)
      end

      puts "[Forest][Shopify] Syncing Products" if Rails.env.development?

      # Look up and store products in a cahe to help limit N+1 query
      record_cache = Forest::Shopify::Product.where(shopify_id_base64: products.collect { |p| Forest::Shopify::Storefront.encode_shopify_id(p.id) })

      products.each do |product|
        product_id_base_64 = Forest::Shopify::Storefront.encode_shopify_id(product.id)
        matched_shopify_ids << product_id_base_64

        forest_shopify_product = record_cache.find { |r| r.shopify_id_base64 == product_id_base_64 }.presence || Forest::Shopify::Product.find_or_initialize_by(shopify_id_base64: product_id_base_64)

        puts "[Forest][Shopify] -- #{product.title}" if Rails.env.development?

        metafields = Forest::Shopify::Product::METAFIELD_IDENTIFIERS.present? ? product.metafields.reject(&:blank?) : []
        metafields_hash = {}
        metafields.each { |m| metafields_hash[m.key] = m.value }

        forest_shopify_product.assign_attributes({
          available_for_sale: product.available_for_sale,
          shopify_created_at: DateTime.parse(product.created_at),
          description: product.description,
          description_html: product.description_html.to_s.squish,
          handle: product.handle,
          slug: product.handle,
          shopify_id_base64: product_id_base_64,
          product_type: product.product_type,
          shopify_published_at: DateTime.parse(product.published_at),
          title: product.title,
          status: 'published',
          metafields: metafields_hash
        })
        forest_shopify_product.save! if forest_shopify_product.changed?

        # Images
        images = product.images.edges.collect(&:node)

        # Delete obsolete image records that no longer exist in Shopify
        forest_shopify_product.images.where.not(shopify_id_base64: images.collect(&:id))
        duplicate_image_records = []
        forest_shopify_product.images.group_by(&:shopify_id_base64).each do |shopify_id, records|
          if records.size > 1
            duplicate_image_records.concat(records[0..-2].collect(&:id))
          end
        end
        duplicate_image_records.flatten!
        Forest::Shopify::Image.where(id: duplicate_image_records).destroy_all if duplicate_image_records.present?

        # Videos
        videos = product.media.edges.collect(&:node).select { |n| n.media_content_type == 'VIDEO' }

        # Delete obsolete video records that no longer exist in Shopify
        forest_shopify_product.videos.where.not(shopify_id_base64: videos.collect(&:id))
        duplicate_video_records = []
        forest_shopify_product.videos.group_by(&:shopify_id_base64).each do |shopify_id, records|
          if records.size > 1
            duplicate_video_records.concat(records[0..-2].collect(&:id))
          end
        end
        duplicate_video_records.flatten!
        Forest::Shopify::Video.where(id: duplicate_video_records).destroy_all if duplicate_video_records.present?

        forest_shopify_product.variants.where.not(shopify_id_base64: product.variants.edges.collect(&:node).collect(&:id)).destroy_all
        forest_shopify_product.product_options.where.not(shopify_id_base64: product.options.collect(&:id)).destroy_all

        # TODO: do we need to specify the image association like we do with a collection's image association?
        create_images(images: images, forest_shopify_record: forest_shopify_product)
        create_videos(videos: videos, forest_shopify_record: forest_shopify_product)
        create_variants(product: product, forest_shopify_product: forest_shopify_product)
        create_product_options(product_options: product.options, forest_shopify_record: forest_shopify_product)
        create_product_tags(product_tags: product.tags, forest_shopify_record: forest_shopify_product)
      end

      if has_next_page
        response = Client.query(Query, variables: { after: product_cursor })
        if response.try(:errors).present?
          Rails.logger.error { "[Forest][Error] Forest::Shopify::Storefront::Product.sync failed #{response.errors.messages.to_json}" }
          return
        else
          has_next_page = response.data.products.page_info.has_next_page
        end
      end
    end

    # Set unmatched forest shopify products to hidden status. We do this rather than just delete
    # the products in case the user set the product to draft mode in Shopify and may have content
    # blocks associated with the product in Forest.
    unless shopify_id_base64.present?
      Forest::Shopify::Product.not_hidden.where.not(shopify_id_base64: matched_shopify_ids).find_each { |p| p.update(status: 'hidden') }

      if Setting.has_attribute?(:setting_status)
        Setting.find_or_create_by(slug: LAST_SYNC_SETTING_SLUG, value_type: 'integer', setting_status: 'hidden').update_columns(value: Time.current.to_i)
        Setting.expire_cache!
      end
    end

    true
  end

  def self.create_variants(product:, forest_shopify_product:)
    variants = product.variants
    nodes = variants.edges.collect(&:node)
    has_next_page = variants.page_info.has_next_page
    page_index = 1

    record_cache = Forest::Shopify::Variant.where(forest_shopify_product_id: forest_shopify_product.id, shopify_id_base64: nodes.collect(&:id))

    nodes.each_with_index do |variant, index|
      variant_id_base_64 = Forest::Shopify::Storefront.encode_shopify_id(variant.id)
      forest_shopify_variant = record_cache.find { |r|
        r.forest_shopify_product_id == forest_shopify_product.id &&
        r.shopify_id_base64 == variant_id_base_64
      }.presence || Forest::Shopify::Variant.find_or_initialize_by({
        forest_shopify_product_id: forest_shopify_product.id,
        shopify_id_base64: variant_id_base_64
      })

      selected_options = {}
      variant.selected_options.each { |so| selected_options[so.name] = so.value }

      puts "[Forest][Shopify] ----  #{variant.title}" if Rails.env.development?
      forest_shopify_variant.assign_attributes({
        shopify_id_base64: variant_id_base_64,
        title: variant.title,
        available_for_sale: variant.available_for_sale,
        compare_at_price: variant.compare_at_price_v2&.amount,
        price: variant.price_v2&.amount,
        selected_options: selected_options,
        sku: variant.sku,
        weight: variant.weight,
        weight_unit: variant.weight_unit,
        position: index
      })
      forest_shopify_variant.save! if forest_shopify_variant.changed?

      create_images(images: variant.image, forest_shopify_record: forest_shopify_variant)
    end

    # TODO: handle variant pagination

    true
  end

  def self.create_product_options(product_options:, forest_shopify_record:)
    product_options = Array(product_options)

    record_cache = Forest::Shopify::ProductOption.where(forest_shopify_product_id: forest_shopify_record.id, shopify_id_base64: product_options.collect { |x| Forest::Shopify::Storefront.encode_shopify_id(x.id) })

    product_options.each do |product_option|
      product_option_id_base_64 = Forest::Shopify::Storefront.encode_shopify_id(product_option.id)
      forest_shopify_product_option = record_cache.find { |r|
        r.forest_shopify_product_id == forest_shopify_record.id &&
        r.shopify_id_base64 == product_option_id_base_64
      }.presence || Forest::Shopify::ProductOption.find_or_initialize_by({
        forest_shopify_product_id: forest_shopify_record.id,
        shopify_id_base64: product_option_id_base_64
      })

      forest_shopify_product_option.assign_attributes({
        name: product_option.name,
        values: product_option.values.to_a
      })

      forest_shopify_product_option.save! if forest_shopify_product_option.changed?
    end
  end

  def self.create_product_tags(product_tags:, forest_shopify_record:)
    product_tags = Array(product_tags)

    record_cache = Forest::Shopify::ProductTag.where(name: product_tags)
    product_tags_to_associate = []

    product_tags.each do |product_tag_name|
      forest_shopify_product_tag = record_cache.find { |r|
        r.name == product_tag_name
      }.presence || Forest::Shopify::ProductTag.find_or_initialize_by({
        name: product_tag_name
      })

      forest_shopify_product_tag.save! if forest_shopify_product_tag.changed?

      product_tags_to_associate << forest_shopify_product_tag
    end

    existing_product_tags_array = forest_shopify_record.product_tags.to_a

    product_tags_to_associate.each do |product_tag|
      # Associate the product tags with the product if the tag doesn't already exist
      forest_shopify_record.product_tags << product_tag unless existing_product_tags_array.include?(product_tag)
    end

    # Find any product tag associations that exist, but weren't in the product_tags_to_associate list. Remove these obsolete tags.
    product_tags_to_remove = (forest_shopify_record.product_tags - product_tags_to_associate | product_tags_to_associate - forest_shopify_record.product_tags)
    forest_shopify_record.product_tags.destroy(product_tags_to_remove)

    # Make sure associations are unique without actually triggering a database update if they are already distinct.
    forest_shopify_record.product_tags = forest_shopify_record.product_tags.uniq
  end
end
