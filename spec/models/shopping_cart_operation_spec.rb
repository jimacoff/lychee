require 'rails_helper'

RSpec.describe ShoppingCartOperation, type: :model, site_scoped: true do
  subject { build(:shopping_cart_operation) }

  has_context 'commodity reference', indexed: false do
    let(:factory) { :shopping_cart_operation }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:item_uuid).of_type(:uuid) }
    it { is_expected.to have_db_column(:quantity).of_type(:integer) }
    it { is_expected.to have_db_column(:metadata).of_type(:hstore) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:shopping_cart) }
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:variant) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:shopping_cart) }
    it { is_expected.not_to validate_presence_of(:product) }
    it { is_expected.not_to validate_presence_of(:variant) }
    it { is_expected.to validate_presence_of(:item_uuid) }
    it { is_expected.to validate_presence_of(:quantity) }
    it { is_expected.not_to validate_presence_of(:metadata) }
  end
end
