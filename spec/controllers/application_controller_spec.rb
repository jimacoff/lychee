require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:site) { create(:site) }
  let(:host) { Faker::Internet.domain_name }
  let!(:tenant) { create(:tenant, site: site, identifier: host) }

  controller do
    def index
      head :ok
    end
  end

  before { @request.host = host }

  Thread.new do
    before(:each) { Site.current = nil }

    context 'without request' do
      it 'has no @site assignment' do
        expect(assigns(:site)).to be_nil
      end
    end

    context 'with request' do
      before { get :index }

      it 'assigns Thread.current[:current_site]' do
        expect(Site.current).to eq(site)
      end

      it 'assigns @site' do
        expect(assigns(:site)).to eq(site)
      end

      it 'has 200 status code' do
        expect(response.status).to eq(200)
      end
    end
  end
end
