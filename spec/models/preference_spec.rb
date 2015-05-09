require 'rails_helper'

RSpec.describe Preference, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :preference }
    let(:site_factory_instances) { 1 }
  end
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:prices_include_tax).of_type(:boolean) }
    it { is_expected.to have_db_column(:tax_basis).of_type(:integer) }

    it 'should have non nullable column site_id of type bigint' do
      expect(subject).to have_db_column(:site_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:site_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:site).class_name('Site') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :tax_basis }

    it 'stores an enum for taxation calculations basis' do
      expect(subject).to define_enum_for(:tax_basis)
        .with([:delivery, :customer, :subscriber])
    end

    context 'instance validations' do
    end
  end
end
