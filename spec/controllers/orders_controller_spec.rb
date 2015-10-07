require 'rails_helper'

RSpec.describe OrdersController, type: :controller, site_scoped: true do
  describe '#create' do
    let(:bag) { create(:shopping_bag) }
    let!(:product) { create(:product) }
    let(:user_agent) { Faker::Lorem.sentence }
    let(:ip) { Faker::Internet.ip_v4_address }
    let(:country_code) { Faker::Address.country_code }
    let(:geoip_latitude) { Faker::Address.latitude }
    let(:geoip_longitude) { Faker::Address.longitude }

    before do
      request.user_agent = user_agent
      request.env.merge!('REMOTE_ADDR' => '127.0.0.1',
                         'HTTP_X_FORWARDED_FOR' => ip,
                         'HTTP_X_GEOIP_COUNTRY_CODE' => country_code,
                         'HTTP_X_GEOIP_LATITUDE' => geoip_latitude,
                         'HTTP_X_GEOIP_LONGITUDE' => geoip_longitude)

      session[:shopping_bag_id] = bag.id
      bag.apply(product_id: product.id, quantity: 1)
    end

    def run
      post :create
    end

    it 'creates an order' do
      expect { run }.to change(Order, :count).by(1)
    end

    it 'redirects to the order' do
      run
      expect(response).to redirect_to(order_path)
    end

    it 'sets the order in the session' do
      run
      expect(session[:order_id]).to eq(Order.last.id)
    end

    it 'stores the metadata in the order' do
      run
      expect(Order.last.metadata)
        .to include('user_agent' => user_agent, 'ip' => ip,
                    'country_code' => country_code,
                    'geoip_latitude' => geoip_latitude,
                    'geoip_longitude' => geoip_longitude)
    end
  end

  describe '#show' do
    let(:order) { create(:order) }

    before do
      session[:order_id] = order.try(:id)
      get :show
    end

    it 'assigns the order' do
      expect(assigns[:order]).to eq(order)
    end

    it 'renders the template' do
      expect(response).to render_template('orders/show')
    end

    context 'with no order' do
      let(:order) { nil }

      it 'redirects to the shopping bag' do
        expect(response).to redirect_to(shopping_bag_path)
      end
    end
  end
end
