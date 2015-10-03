require 'rails_helper'

RSpec.describe ShoppingBagsController, type: :routing do
  context 'get /shop/bag' do
    subject { { get: '/shop/bag' } }
    it { is_expected.to route_to('shopping_bags#show') }
  end

  context 'post /shop/bag' do
    subject { { post: '/shop/bag' } }
    it { is_expected.to route_to('shopping_bags#add') }
  end

  context 'patch /shop/bag' do
    subject { { patch: '/shop/bag' } }
    it { is_expected.to route_to('shopping_bags#update') }
  end

  context 'delete /shop/bag' do
    subject { { delete: '/shop/bag' } }
    it { is_expected.to route_to('shopping_bags#destroy') }
  end
end
