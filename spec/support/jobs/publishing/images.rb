RSpec.shared_examples 'jobs::publishing::images' do
  # rubocop:disable Metrics/MethodLength
  def image_file_json(image_file)
    image = {
      id: image_file.id,
      filename: image_file.filename,
      width: image_file.width
    }
    image[:x_dimension] = image_file.x_dimension if image_file.x_dimension
    image[:height] = image_file.height if image_file.height

    if image_file.metadata
      image[:metadata] = image_file.metadata.symbolize_keys!
    end

    image
  end
  # rubocop:enable Metrics/MethodLength

  context 'image_instance' do
    let(:builder) do
      Jbuilder.encode do |json|
        described_class.new.image_instance(json, image_instance)
      end
    end
    subject { JSON.parse(builder, symbolize_names: true) }

    let(:image) { create(:image) }
    let(:image_instance) { create :image_instance, image: image, site: site }

    let(:json) do
      i = image_instance.image
      {
        id: image_instance.id,
        image: {
          id: i.id,
          name: i.name,
          description: i.description,
          internal_name: i.internal_name,
          extension: i.extension,
          original_image: image_file_json(i.image_files.original_image),
          default_image: image_file_json(i.image_files.default_image),
          srcset: image.image_files.srcset.map { |e| image_file_json(e) }
        }
      }
    end
    let(:metadata) { { key: Faker::Lorem.word } }

    context 'with minimal data' do
      it { is_expected.to match(json) }
    end

    context 'with metadata' do
      let(:image_instance) do
        create :image_instance, image: image, metadata: metadata, site: site
      end
      before { json[:metadata] = metadata }

      it { is_expected.to match(json) }
    end

    context 'images' do
      context 'with metadata' do
        let(:image) { create(:image, metadata: metadata) }
        before { json[:image][:metadata] = metadata }

        it { is_expected.to match(json) }
      end

      context 'with tags' do
        let(:tags) { Faker::Lorem.words(2) }
        let(:image) { create(:image, tags: tags) }
        before { json[:image][:tags] = tags }

        it { is_expected.to match(json) }
      end

      shared_examples 'image_file behaviour' do
        context 'with x_dimension' do
          let(:x_dimension) { Faker::Lorem.word }
          before do
            target_instance.update!(x_dimension: x_dimension)
            target_json[:x_dimension] = x_dimension
          end

          it { is_expected.to match(json) }
        end

        context 'with height' do
          let(:height) { Faker::Lorem.word }
          before do
            target_instance.update!(height: height)
            target_json[:height] = height
          end

          it { is_expected.to match(json) }
        end

        context 'with metadata' do
          before do
            target_instance.update!(metadata: metadata)
            target_json[:metadata] = metadata
          end

          it { is_expected.to match(json) }
        end
      end

      context 'original_image' do
        include_examples 'image_file behaviour' do
          let(:target_instance) { image.image_files.original_image }
          let(:target_json) { json[:image][:original_image] }
        end
      end

      context 'default_image' do
        include_examples 'image_file behaviour' do
          let(:target_instance) { image.image_files.default_image }
          let(:target_json) { json[:image][:default_image] }
        end
      end

      context 'srcset' do
        include_examples 'image_file behaviour' do
          let(:srcset_instance) { rand(0..2) }
          let(:target_instance) { image.image_files.srcset[srcset_instance] }
          let(:target_json) { json[:image][:srcset][srcset_instance] }
        end
      end
    end
  end
end
