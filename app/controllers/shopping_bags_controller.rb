class ShoppingBagsController < ApplicationController
  after_action :saas_template, only: :show

  def add
    @product = Product.find(params[:product_id])
    attrs = { quantity: 1, metadata: submissible_metadata(params) }

    params[:variations] ? add_variant(attrs) : add_product(attrs)
    flash[:updated] = false
    redirect_to :shopping_bag
  end

  def update
    operations.each { |op| bag.apply(op) }
    flash[:updated] = true
    redirect_to :shopping_bag
  rescue ActionController::ParameterMissing
    render nothing: true
  end

  def show
    @contents = bag.contents.values
    render layout: false
  end

  private

  def saas_template
    new_body = template.gsub(/__yield_shopping_bag__/, response.body)
    response.body = new_body
  end

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
    @bag = ShoppingBag.find_by(id: id) if id
    @bag ||= ShoppingBag.create!.tap { |c| session[:shopping_bag_id] = c.id }
  end

  def operations
    params.require(:operations).map do |op|
      op[:quantity] = 0 if op[:additional_action] == 'remove'

      op.permit(:product_id, :variant_id, :quantity, :item_uuid)
        .merge(metadata: submissible_metadata(op))
    end
  end

  def submissible_metadata(params)
    metadata = params[:metadata]
    return {} unless metadata.present?

    metadata.permit(submissible_metadata_keys(params[:product_id],
                                              params[:variant_id]))
  end

  def submissible_metadata_keys(product_id, variant_id)
    product = referenced_product(product_id, variant_id)
    return [] unless product.metadata_fields.present?
    product.metadata_fields.select { |_, v| v['submissible'] }.keys
  end

  def referenced_product(product_id, variant_id)
    product_id ? Product.find(product_id) : Variant.find(variant_id).product
  end

  def controller_template
    Rails.configuration.zepily.sites.themes.templates.bag
  end
end
