require 'rails_helper'

RSpec.describe ShoppingBagsController, type: :routing do
  context 'get /shopping-cart' do
    subject { { get: '/shopping-cart' } }
    it { is_expected.to route_to('shopping_bags#show') }
  end

  context 'post /shopping-cart' do
    subject { { post: '/shopping-cart' } }
    it { is_expected.to route_to('shopping_bags#add') }
  end

  context 'patch /shopping-cart' do
    subject { { patch: '/shopping-cart' } }
    it { is_expected.to route_to('shopping_bags#update') }
  end

  context 'delete /shopping-cart' do
    subject { { delete: '/shopping-cart' } }
    it { is_expected.to route_to('shopping_bags#destroy') }
  end
end
