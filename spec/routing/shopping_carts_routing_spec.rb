require 'rails_helper'

RSpec.describe ShoppingCartsController, type: :routing do
  context 'get /shopping-cart' do
    subject { { get: '/shopping-cart' } }
    it { is_expected.to route_to('shopping_carts#show') }
  end

  context 'patch /shopping-cart' do
    subject { { patch: '/shopping-cart' } }
    it { is_expected.to route_to('shopping_carts#update') }
  end

  context 'delete /shopping-cart' do
    subject { { delete: '/shopping-cart' } }
    it { is_expected.to route_to('shopping_carts#destroy') }
  end
end
