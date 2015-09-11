require 'rails_helper'

RSpec.describe Image, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :image }
  end
  has_context 'versioned'
  has_context 'metadata'
  has_context 'taggable'

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:internal_name).of_type(:string) }
    it { is_expected.to have_db_column(:extension).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }

    it { is_expected.to have_db_index([:site_id, :internal_name]).unique }
  end

  context 'relationships' do
    it { is_expected.to have_many :image_files }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :internal_name }
    it { is_expected.to validate_presence_of :extension }
    it { is_expected.to validate_presence_of :description }

    context 'instance validations' do
      subject { create :image }
      it { is_expected.to be_valid }

      it 'is invalid without default_image' do
        subject.image_files.default_image.update!(default_image: false)
        subject.valid?
        expect(subject.errors).to have_key(:default_image)
      end

      it 'is invalid without default_image' do
        subject.image_files.original_image.update!(original_image: false)
        subject.valid?
        expect(subject.errors).to have_key(:original_image)
      end
    end

    context 'image_files association extensions' do
      subject { create :image }

      describe '#base_image' do
        let(:image_file) { subject.image_files.last }
        it 'provides the default image file' do
          image_file.default_image = true
          image_file.save

          expect(subject.image_files.default_image).to eq(image_file)
        end
      end

      describe '#original_image' do
        let(:image_file) { subject.image_files.first }
        it 'provides the original image file' do
          image_file.original_image = true
          image_file.save

          expect(subject.image_files.original_image).to eq(image_file)
        end
      end

      describe '#srcset' do
        it 'provides the default image file' do
          expect(subject.image_files.srcset.length)
            .to eq(subject.image_files.length - 2)
        end
      end
    end
  end
end
