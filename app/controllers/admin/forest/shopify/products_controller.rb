class Admin::Forest::Shopify::ProductsController < Admin::ForestController
  before_action :set_product, only: [:edit, :update, :destroy]

  def index
    @pagy, @products = pagy apply_scopes(Forest::Shopify::Product.by_id)
  end

  def new
    @product = Forest::Shopify::Product.new
    authorize @product
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
    # TODO: move to a background job
    if Forest::Shopify::Storefront::Product.sync
      notice = 'Products were successfully synced.'
    else
      notice = 'Products failed to sync.'
    end

    redirect_to admin_forest_shopify_products_path, notice: notice
  end

  private

  def product_params
    # Add blockable params to the permitted attributes if this record is blockable `**BlockSlot.blockable_params`
    params.require(:product).permit(:slug, :status, :available_for_sale, :shopify_created_at, :description, :description_html, :handle, :shopify_id, :shopify_id_base64, :product_type, :shopify_published_at, :title, **BlockSlot.blockable_params)
  end

  def set_product
    @product = Forest::Shopify::Product.find(params[:id])
  end
end
