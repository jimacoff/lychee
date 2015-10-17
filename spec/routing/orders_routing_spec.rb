require 'rails_helper'

RSpec.describe OrdersController, type: :routing do
  context 'get /shop/order' do
    subject { { get: '/shop/order' } }
    it { is_expected.to route_to('orders#show') }
  end

  context 'post /shop/order' do
    subject { { post: '/shop/order' } }
    it { is_expected.to route_to('orders#create') }
  end

  context 'patch /shop/order' do
    subject { { patch: '/shop/order' } }
    it { is_expected.to route_to('orders#update') }
  end

  context 'delete /shop/order' do
    subject { { delete: '/shop/order' } }
    it { is_expected.to route_to('orders#destroy') }
  end
end
