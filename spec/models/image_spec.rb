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

      describe '#default_image' do
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
        it 'all images except the original' do
          expect(subject.image_files.srcset.length)
            .to eq(subject.image_files.length - 1)

          expect(subject.image_files.srcset)
            .not_to include(subject.image_files.original_image)
        end
      end
    end

    describe '#default_path' do
      subject { create :image }
      let(:image_file) { subject.image_files.last }

      it 'provides the default image file path' do
        image_file.default_image = true
        image_file.save

        expect(subject.default_path).to eq(image_file.path)
      end
    end

    describe '#srcset_path' do
      subject { create :image }
      let(:image_file) { subject.image_files.first }
      let(:expected_srcset_path) do
        subject.image_files.srcset.map(&:srcset_path).join(', ')
      end

      it 'provides the default image file path' do
        image_file.original_image = true
        image_file.save

        expect(subject.srcset_path).to eq(expected_srcset_path)
      end
    end
  end
end
