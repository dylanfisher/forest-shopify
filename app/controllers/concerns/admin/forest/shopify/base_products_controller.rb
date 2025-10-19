module Admin::Forest::Shopify
  module BaseProductsController
    extend ActiveSupport::Concern

    included do
      before_action :set_product, only: [:edit, :update, :destroy]
    end

    def index
      @pagy, @products = pagy apply_scopes(Forest::Shopify::Product.includes(:featured_media_item)).by_slug
      authorize @products
    end

    def edit
      authorize @product
    end

    def create
      @product = Forest::Shopify::Product.new(product_params)
      authorize @product

      if @product.save
        redirect_to edit_admin_forest_shopify_product_path(@product), notice: 'Product was successfully created.'
      else
        render :new
      end
    end

    def update
      authorize @product

      if @product.update(product_params)
        redirect_to edit_admin_forest_shopify_product_path(@product), notice: 'Product was successfully updated.'
      else
        render :edit
      end
    end

    def destroy
      authorize @product
      @product.destroy
      redirect_to admin_forest_shopify_products_url, notice: 'Product was successfully destroyed.'
    end

    def sync
      authorize [:forest, :shopify, :product], :sync?

      if Forest::Shopify::SyncProductsJob.perform_later
        notice = 'Product sync initiated in a background process. This may take some time to complete depending on how large your store is.'
      else
        notice = 'Products failed to sync.'
      end

      redirect_to admin_forest_shopify_products_path, notice: notice
    end

    private

    def product_params
      # Add blockable params to the permitted attributes if this record is blockable `**BlockSlot.blockable_params`
      params.require(:product).permit(permitted_params)
    end

    def base_product_params
      [:slug, :status, :available_for_sale, :shopify_created_at, :description, :description_html, :handle, :shopify_id, :shopify_id_base64, :product_type, :shopify_published_at, :title, **BlockSlot.blockable_params]
    end

    # Override in your host app if you need to add additional attributes
    def permitted_params
      base_product_params
    end

    def set_product
      @product = Forest::Shopify::Product.find(params[:id])
    end
  end
end
