require 'rails_helper'
require 'closure_tree/test/matcher'

RSpec.describe Path, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :path }
  end
  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:segment).of_type(:string) }
    it { is_expected.to have_db_column(:parent_id).of_type(:integer) }

    it 'should have non nullable column routable_id of type bigint' do
      expect(subject).to have_db_column(:routable_id)
        .of_type(:integer)
        .with_options(limit: 8, null: true)
    end
    it { is_expected.to have_db_column(:routable_type).of_type(:string) }
    it { is_expected.to have_db_index([:routable_type, :routable_id]) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:routable) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :segment }

    context 'instance validations' do
      subject { create :path }
      it { is_expected.to be_a_closure_tree.ordered }
    end
  end
end
