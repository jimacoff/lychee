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

    context 'unique image files' do
      let(:image) { create :image, :with_image_files }
      let(:image_file1) { image.image_files.first }
      let(:image_file2) { image.image_files.last }

      it 'validates that only one image_file is set to default' do
        image_file1.default_image = true
        image_file1.save!
        expect(image_file1).to be_valid

        image_file2.default_image = true
        expect(image_file2).not_to be_valid
      end

      it 'validates that only one image_file is set to original' do
        image_file1.original_image = true
        image_file1.save!
        expect(image_file1).to be_valid

        image_file2.original_image = true
        expect(image_file2).not_to be_valid
      end
    end
  end
end
