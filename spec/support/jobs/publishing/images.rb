RSpec.shared_examples 'jobs::publishing::images' do
  # rubocop:disable Metrics/MethodLength
  def image_file_json(image_file, srcset_path = false)
    image = {
      id: image_file.id,
      filename: image_file.filename,
      width: image_file.width,
      height: image_file.height,
      path: image_file.path,
      x_dimension: image_file.x_dimension,
      metadata: image_file.metadata.try(:symbolize_keys)
    }.compact
    image[:srcset_path] = image_file.srcset_path if srcset_path
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
        name: image_instance.name,
        description: image_instance.description,
        data: {
          id: i.id,
          internal_name: i.internal_name,
          extension: i.extension,
          original: image_file_json(i.image_files.original_image),
          default: image_file_json(i.image_files.default_image),
          srcset: image.image_files.srcset.map { |e| image_file_json(e, true) }
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
        before { json[:data][:metadata] = metadata }

        it { is_expected.to match(json) }
      end

      context 'with tags' do
        let(:tags) { Faker::Lorem.words(2) }
        let(:image) { create(:image, tags: tags) }
        before { json[:data][:tags] = tags }

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

      context 'original' do
        include_examples 'image_file behaviour' do
          let(:target_instance) { image.image_files.original_image }
          let(:target_json) { json[:data][:original] }
        end
      end

      context 'default_image' do
        include_examples 'image_file behaviour' do
          let(:target_instance) { image.image_files.default_image }
          let(:target_json) { json[:data][:default] }
        end
      end

      context 'srcset' do
        include_examples 'image_file behaviour' do
          let(:srcset_instance) { rand(0..2) }
          let(:target_instance) { image.image_files.srcset[srcset_instance] }
          let(:target_json) { json[:data][:srcset][srcset_instance] }
        end
      end
    end
  end
end
