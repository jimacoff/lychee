class ShoppingCartsController < ApplicationController
  def update
    operations.each { |op| cart.apply(op) }
    render nothing: true
  rescue ActionController::ParameterMissing
    render nothing: true
  end

  private

  def cart
    id = session[:shopping_cart_id]
    return @cart = ShoppingCart.find(id) if id

    @cart = ShoppingCart.create!.tap { |c| session[:shopping_cart_id] = c.id }
  end

  def operations
    params.require(:shopping_cart).map do |op|
      op.permit(:product_id, :variant_id, :quantity, :item_uuid)
        .merge(metadata: op[:metadata].try(:to_unsafe_hash))
    end
  end
end
