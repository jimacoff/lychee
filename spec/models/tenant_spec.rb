require 'rails_helper'

RSpec.describe Tenant, type: :model do
  context 'table structure' do
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
    it { is_expected.to validate_presence_of :site }
    it { is_expected.to validate_presence_of :identifier }
  end
end
