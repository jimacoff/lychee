class ShoppingCartsController < ApplicationController
  def add
    @product = Product.find(params[:product_id])
    attrs = { quantity: 1, metadata: params[:metadata] }

    params[:variations] ? add_variant(attrs) : add_product(attrs)
    redirect_to :shopping_cart
  end

  def update
    operations.each { |op| cart.apply(op) }
    redirect_to :shopping_cart
  rescue ActionController::ParameterMissing
    render nothing: true
  end

  def show
    @contents = cart.contents.values
  end

  private

  def add_product(attrs)
    fail("Product #{@product.id} needs variations") if @product.variants.any?
    cart.apply(attrs.merge(product_id: @product.id))
  end

  def add_variant(attrs)
    @variant = @product.variant(params[:variations])
    cart.apply(attrs.merge(variant_id: @variant.try(:id)))
  end

  def cart
    id = session[:shopping_cart_id]
    return @cart = ShoppingCart.find(id) if id

    @cart = ShoppingCart.create!.tap { |c| session[:shopping_cart_id] = c.id }
  end

  def operations
    params.require(:operations).map do |op|
      op.permit(:product_id, :variant_id, :quantity, :item_uuid)
        .merge(metadata: op[:metadata].try(:to_unsafe_hash))
    end
  end
end
