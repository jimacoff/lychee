class ShoppingBagsController < ApplicationController
  def add
    @product = Product.find(params[:product_id])
    attrs = { quantity: 1, metadata: params[:metadata] }

    params[:variations] ? add_variant(attrs) : add_product(attrs)
    redirect_to :shopping_bag
  end

  def update
    operations.each { |op| bag.apply(op) }
    redirect_to :shopping_bag
  rescue ActionController::ParameterMissing
    render nothing: true
  end

  def show
    @contents = bag.contents.values
  end

  private

  def add_product(attrs)
    fail("Product #{@product.id} needs variations") if @product.variants.any?
    bag.apply(attrs.merge(product_id: @product.id))
  end

  def add_variant(attrs)
    @variant = @product.variant(params[:variations])
    bag.apply(attrs.merge(variant_id: @variant.try(:id)))
  end

  def bag
    id = session[:shopping_bag_id]
    @bag = ShoppingBag.find_by_id(id) if id
    @bag ||= ShoppingBag.create!.tap { |c| session[:shopping_bag_id] = c.id }
  end

  def operations
    params.require(:operations).map do |op|
      op.permit(:product_id, :variant_id, :quantity, :item_uuid)
        .merge(metadata: op[:metadata].try(:to_unsafe_hash))
    end
  end
end
