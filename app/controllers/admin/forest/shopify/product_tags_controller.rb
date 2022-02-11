class Admin::Forest::Shopify::ProductTagsController < Forest::Shopify::AdminController
  before_action :set_product_tag, only: [:edit, :update, :destroy]

  def index
    @pagy, @product_tags = pagy apply_scopes(Forest::Shopify::ProductTag).by_name
    authorize @product_tags
    @product_tag_product_counts = @product_tags.unscope(:order).joins(:products).group(:forest_shopify_product_tag_id).count(:forest_shopify_product_id)
  end

  def new
    @product_tag = Forest::Shopify::ProductTag.new
    authorize @product_tag
  end

  def edit
    authorize @product_tag
  end

  def create
    @product_tag = Forest::Shopify::ProductTag.new(product_tag_params)
    authorize @product_tag

    if @product_tag.save
      redirect_to edit_admin_forest_shopify_product_tag_path(@product_tag), notice: 'Product tag was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @product_tag

    if @product_tag.update(product_tag_params)
      redirect_to edit_admin_forest_shopify_product_tag_path(@product_tag), notice: 'Product tag was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @product_tag
    @product_tag.destroy
    redirect_to admin_forest_shopify_product_tags_url, notice: 'Product tag was successfully destroyed.'
  end

  private

  def product_tag_params
    # Add blockable params to the permitted attributes if this record is blockable `**BlockSlot.blockable_params`
    params.require(:product_tag).permit(:name, :media_item_id)
  end

  def set_product_tag
    @product_tag = Forest::Shopify::ProductTag.find(params[:id])
  end
end
