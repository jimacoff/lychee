require 'rails_helper'

RSpec.describe ShoppingCart, type: :model, site_scoped: true do
  subject { create(:shopping_cart) }

  has_context 'parent site' do
    let(:factory) { :shopping_cart }
  end

  context 'table structure' do
    it { is_expected.to have_db_column(:workflow_state).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:site) }
    it { is_expected.to have_many(:shopping_cart_operations) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :site }

    # Error condition can't be triggered, but the validation is there:
    # it { is_expected.to validate_presence_of :workflow_state }
  end

  context 'workflow' do
    it_behaves_like 'workflow object', transitions: [], state: :active
    it_behaves_like 'workflow object', transitions: [:abandon],
                                       state: :abandoned
    it_behaves_like 'workflow object', transitions: [:cancel],
                                       state: :cancelled
    it_behaves_like 'workflow object', transitions: [:checkout],
                                       state: :checked_out
    it_behaves_like 'workflow object', transitions: [:checkout, :abandon],
                                       state: :abandoned
    it_behaves_like 'workflow object', transitions: [:checkout, :cancel],
                                       state: :cancelled
  end
end
