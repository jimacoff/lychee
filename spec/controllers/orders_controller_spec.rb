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

    it 'submits the order' do
      run
      expect(Order.last.workflow_state).to eq('collecting')
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

  describe '#update' do
    let(:order) { create(:order, customer: nil, recipient: nil) }
    let(:country) { create(:country) }
    let(:state) { create(:state, country: country) }

    before { order.submit! }

    context 'supplying customer details' do
      let(:customer_attrs) { attributes_for(:person) }
      let(:transition_params) { { transition: 'calculate' } }

      let(:customer_address_attrs) do
        attributes_for(:address, country_id: country.id, state_id: state.id)
      end

      before do
        session[:order_id] = order.try(:id)
      end

      def run
        patch :update, transition_params.merge(order: order_attrs)
      end

      shared_examples 'updates person details in order' do
        it 'stores the customer' do
          run
          person = order.reload.customer
          expect(person).not_to be_nil
          expect(person).to have_attributes(customer_attrs)
          expect(person.address).to have_attributes(customer_address_attrs)
        end

        it 'stores the recipient' do
          run
          person = order.reload.recipient
          expect(person).not_to be_nil
          expect(person).to have_attributes(recipient_attrs)
          expect(person.address).to have_attributes(recipient_address_attrs)
        end
      end

      shared_examples 'a transition to :pending' do
        it 'updates the workflow_state' do
          expect { run }.to change { order.reload.workflow_state }.to('pending')
        end

        context 'with an invalid transition' do
          let(:transition_params) { { transition: 'destroy' } }

          it 'rejects the change' do
            expect { run }.to raise_error('bad transition')
          end
        end
      end

      context 'with customer details used as recipient details' do
        let(:recipient_attrs) { customer_attrs }
        let(:recipient_address_attrs) { customer_address_attrs }

        let(:order_attrs) do
          { customer: customer_attrs.merge(address: customer_address_attrs),
            use_billing_details_for_shipping: '1' }
        end

        it 'creates exactly one person' do
          expect { run }.to change(Person, :count).by(1)
        end

        include_examples 'updates person details in order'

        it 'uses the same person for both entries' do
          run
          order.reload
          expect(order.customer).to eq(order.recipient)
        end

        it_behaves_like 'a transition to :pending'

        context 'when the order already has people' do
          let(:order) { create(:order) }
          let(:transition_params) { {} }

          before { order.calculate! }

          it 'removes the additional person' do
            expect { run }.to change(Person, :count).by(-1)
          end

          include_examples 'updates person details in order'
        end
      end

      context 'with separate recipient details' do
        let(:recipient_attrs) { attributes_for(:person) }

        let(:recipient_address_attrs) do
          attributes_for(:address, country_id: country.id, state_id: state.id)
        end

        let(:order_attrs) do
          { customer: customer_attrs.merge(address: customer_address_attrs),
            recipient: recipient_attrs.merge(address: recipient_address_attrs) }
        end

        include_examples 'updates person details in order'

        it_behaves_like 'a transition to :pending'

        context 'when the order already has people' do
          let(:order) { create(:order) }
          let(:transition_params) { {} }

          before { order.calculate! }

          it 'does not change the total number of people' do
            expect { run }.not_to change(Person, :count)
          end

          include_examples 'updates person details in order'
        end
      end
    end
  end

  describe '#destroy' do
    pending 'cancels the order'
  end
end
