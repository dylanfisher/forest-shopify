class Admin::Forest::Shopify::VariantsController < Forest::Shopify::AdminController
  before_action :set_variant, only: [:edit, :update, :destroy]

  def index
    @pagy, @variants = pagy apply_scopes(Forest::Shopify::Variant).by_slug
    authorize @variants
  end

  def new
    @variant = Forest::Shopify::Variant.new
    authorize @variant
  end

  def edit
    authorize @variant
  end

  def create
    @variant = Forest::Shopify::Variant.new(variant_params)
    authorize @variant

    if @variant.save
      redirect_to edit_admin_forest_shopify_variant_path(@variant), notice: 'Variant was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @variant

    if @variant.update(variant_params)
      redirect_to edit_admin_forest_shopify_variant_path(@variant), notice: 'Variant was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @variant
    @variant.destroy
    redirect_to admin_forest_shopify_variants_url, notice: 'Variant was successfully destroyed.'
  end

  private

  def variant_params
    # Add blockable params to the permitted attributes if this record is blockable `**BlockSlot.blockable_params`
    params.require(:variant).permit(:slug, :status, :title, :shopify_id_base64, :price, :availableForSale, :compareAtPrice, :sku, :weight, :weightUnit, :position, :forest_shopify_product_id)
  end

  def set_variant
    @variant = Forest::Shopify::Variant.find(params[:id])
  end
end
