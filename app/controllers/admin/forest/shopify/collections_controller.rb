class Admin::Forest::Shopify::CollectionsController < Forest::Shopify::AdminController
  before_action :set_collection, only: [:edit, :update, :destroy]

  def index
    @pagy, @collections = pagy apply_scopes(Forest::Shopify::Collection).by_slug
    authorize @collections
  end

  def new
    @collection = Forest::Shopify::Collection.new
    authorize @collection
  end

  def edit
    authorize @collection
    @pagy, @products = pagy apply_scopes(@collection.products.includes(:featured_media_item)).by_slug
  end

  def create
    @collection = Forest::Shopify::Collection.new(collection_params)
    authorize @collection

    if @collection.save
      redirect_to edit_admin_forest_shopify_collection_path(@collection), notice: 'Forest::Shopify::Collection was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize @collection

    if @collection.update(collection_params)
      redirect_to edit_admin_forest_shopify_collection_path(@collection), notice: 'Forest::Shopify::Collection was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @collection
    @collection.destroy
    redirect_to admin_forest_shopify_collections_url, notice: 'Forest::Shopify::Collection was successfully destroyed.'
  end

  def sync
    authorize [:forest, :shopify, :collection], :sync?

    if Forest::Shopify::SyncCollectionsJob.perform_later
      notice = 'Collection sync initiated in a background process. This may take some time to complete depending on how large your store is.'
    else
      notice = 'Collections failed to sync.'
    end

    redirect_to admin_forest_shopify_collections_path, notice: notice
  end

  private

  def collection_params
    # Add blockable params to the permitted attributes if this record is blockable `**BlockSlot.blockable_params`
    params.require(:collection).permit(:slug, :status, :description, :description_html, :handle, :shopify_id, :shopify_id_base64, :shopify_published_at, :title, :slug, **BlockSlot.blockable_params)
  end

  def set_collection
    @collection = Forest::Shopify::Collection.find(params[:id])
  end
end
