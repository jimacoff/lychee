require 'rails_helper'

RSpec.describe OrdersController, type: :routing do
  context 'get /shop/checkout' do
    subject { { get: '/shop/checkout' } }
    it { is_expected.to route_to('orders#show') }
  end

  context 'post /shop/checkout' do
    subject { { post: '/shop/checkout' } }
    it { is_expected.to route_to('orders#create') }
  end

  context 'patch /shop/checkout' do
    subject { { patch: '/shop/checkout' } }
    it { is_expected.to route_to('orders#update') }
  end
end
