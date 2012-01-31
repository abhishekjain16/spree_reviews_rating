class ReviewsController < Spree::BaseController
  helper Spree::BaseHelper
  
  before_filter :load_product, :only => [:index, :new, :create]
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  def index
    @approved_reviews = Review.approved.find_all_by_product_id(@product.id)
  end
  
  def all_list
    @approved_reviews = Review.approved.order("created_at DESC")
    respond_to do |f|
      f.html
    end
  end

  def new
    @review = Review.new(:product => @product)
    authorize! :new, @review
    render :layout => false
  end

  # save if all ok
  def create
    #params[:review][:rating].sub!(/\s*stars/,'') unless params[:review][:rating].blank?

    @review = Review.new(params[:review])
    @review.product = @product
    @review.user = current_user if user_signed_in?
    @review.location = request.remote_ip

    authorize! :create, @review

    if @review.save
      flash[:notice] = t('review_successfully_submitted')
      redirect_to (product_path(@product))
    else
      render :action => "new"
    end
  end

  def terms
  end

  private

    def load_product
      @product = Product.find_by_permalink!(params[:product_id])
    end

end
