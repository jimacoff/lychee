require 'rails_helper'

RSpec.describe ShoppingBagsController, type: :routing do
  context 'get /shopping-bag' do
    subject { { get: '/shopping-bag' } }
    it { is_expected.to route_to('shopping_bags#show') }
  end

  context 'post /shopping-bag' do
    subject { { post: '/shopping-bag' } }
    it { is_expected.to route_to('shopping_bags#add') }
  end

  context 'patch /shopping-bag' do
    subject { { patch: '/shopping-bag' } }
    it { is_expected.to route_to('shopping_bags#update') }
  end

  context 'delete /shopping-bag' do
    subject { { delete: '/shopping-bag' } }
    it { is_expected.to route_to('shopping_bags#destroy') }
  end
end
