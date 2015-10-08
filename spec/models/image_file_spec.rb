require 'rails_helper'

RSpec.describe ImageFile, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :image_file }
  end
  has_context 'versioned'
  has_context 'metadata'
  has_context 'routable' do
    let(:factory) { :image_file }
  end

  context 'table structure' do
    it { is_expected.not_to have_db_column(:filename).of_type(:string) }
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
    it { is_expected.to validate_presence_of :width }
    it { is_expected.to validate_presence_of :height }

    context 'instance validations' do
      subject { create :image_file }
      it { is_expected.to be_valid }
    end

    context 'unique image files' do
      let(:image) { create :image }
      let(:image_file) { image.image_files.srcset.first }

      it 'validates that only one image_file is set to default' do
        image_file.update(default_image: true)
        expect(image_file).not_to be_valid
      end

      it 'validates that only one image_file is set to original' do
        image_file.update(original_image: true)
        expect(image_file).not_to be_valid
      end
    end
  end

  describe '#filename' do
    subject { create :image_file }

    it 'constructs a valid filename' do
      expect(subject.filename).to eq(
        "#{subject.width}.#{subject.height}.#{subject.image.extension}")
    end
  end

  describe '#srcset_path' do
    context 'routable image file' do
      subject { create :image_file, :routable }

      it 'constructs a valid path' do
        expect(subject.srcset_path).to eq(
          "#{subject.site.preferences.reserved_paths['images']}" \
          "/#{subject.image.internal_name}/#{subject.width}.#{subject.height}" \
          ".#{subject.image.extension} #{subject.width}w")
      end

      context 'with x_dimension' do
        it 'constructs a valid path' do
          subject.x_dimension = '2x'
          expect(subject.srcset_path).to eq(
            "#{subject.site.preferences.reserved_paths['images']}" \
            "/#{subject.image.internal_name}/" \
            "#{subject.width}.#{subject.height}" \
            ".#{subject.image.extension} #{subject.x_dimension}")
        end
      end
    end

    describe '#create_default_path' do
      subject { create :image_file }

      shared_examples 'image path behaviours' do
        it 'creates a valid path' do
          expect(subject.path).to be_valid
        end

        it 'creates a path which routes to us' do
          expect(subject.path.routable).to eq(subject)
        end
      end

      context 'When site has reserved image assets path' do
        before { subject.create_default_path }

        include_examples 'image path behaviours'

        it 'sets path uri to include site image assets path' do
          expect(subject.uri_path).to eq(
            "#{subject.site.preferences.reserved_paths['images']}" \
            "/#{subject.image.internal_name}/" \
            "#{subject.width}.#{subject.height}.#{subject.image.extension}")
        end
      end

      context 'When site has reserved image assets path' do
        before do
          subject.site.preferences.reserved_paths.delete('images')
          subject.create_default_path
        end

        include_examples 'image path behaviours'

        it 'sets path uri to include site image assets path' do
          expect(subject.uri_path).to eq(
            "/#{subject.image.internal_name}/" \
            "#{subject.width}.#{subject.height}.#{subject.image.extension}")
        end
      end
    end
  end
end
