require 'rails_helper'

RSpec.describe Image, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :image }
  end
  has_context 'versioned'
  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:description).of_type(:string) }
  end

  context 'relationships' do
    it { is_expected.to have_many :image_files }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :description }

    context 'instance validations' do
      subject { create :image }
      it { is_expected.to be_valid }
    end

    context 'image_files association extensions' do
      subject { create :image, :with_image_files }

      describe '#base_image' do
        let(:image_file) { subject.image_files.last }
        it 'provides the default image file' do
          image_file.default_image = true
          image_file.save

          expect(subject.image_files.default_image).to eq(image_file)
        end
      end

      describe '#original_image' do
        let(:image_file) { subject.image_files.last }
        it 'provides the original image file' do
          image_file.original_image = true
          image_file.save

          expect(subject.image_files.original_image).to eq(image_file)
        end
      end
    end
  end
end
