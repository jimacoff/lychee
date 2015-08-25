require 'rails_helper'

RSpec.describe ImageFile, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :image_file }
  end
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:filename).of_type(:string) }
    it { is_expected.to have_db_column(:width).of_type(:string) }
    it { is_expected.to have_db_column(:height).of_type(:string) }
    it { is_expected.to have_db_column(:x_dimension).of_type(:string) }
    it { is_expected.to have_db_column(:default_image).of_type(:boolean) }
    it { is_expected.to have_db_column(:original_image).of_type(:boolean) }

    it 'should have non nullable column image_id of type bigint' do
      expect(subject).to have_db_column(:image_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
  end

  context 'relationships' do
    it { is_expected.to belong_to(:image).class_name('Image') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :filename }
    it { is_expected.to validate_presence_of :width }

    context 'instance validations' do
      subject { create :image_file }
      it { is_expected.to be_valid }
    end
  end
end
