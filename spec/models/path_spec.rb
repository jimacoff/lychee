require 'rails_helper'
require 'closure_tree/test/matcher'

RSpec.describe Path, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :path }
  end
  has_context 'versioned'

  context 'table structure' do
    it { is_expected.to have_db_column(:segment).of_type(:string) }
    it { is_expected.to have_db_column(:parent_id).of_type(:integer) }

    it 'should have non nullable column routable_id of type bigint' do
      expect(subject).to have_db_column(:routable_id)
        .of_type(:integer)
        .with_options(limit: 8, null: true)
    end
    it { is_expected.to have_db_column(:routable_type).of_type(:string) }
    it { is_expected.to have_db_index([:routable_type, :routable_id]) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:routable) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :segment }

    context 'instance validations' do
      subject { create :path }
      it { is_expected.to be_a_closure_tree.ordered }
    end
  end

  describe '::find_path' do
    context 'path exists' do
      let(:segment1) { Faker::Lorem.word }
      let(:segment2) { Faker::Lorem.word }
      let!(:path_instance) { Path.find_or_create_by_path([segment1, segment2]) }
      subject { Path.find_path(path) }

      context 'passing a / seperated string' do
        let(:path) { "/#{segment1}/#{segment2}" }
        it { is_expected.to eq(path_instance) }
      end

      context 'passing an array of strings in hierarchy' do
        let(:path) { [segment1, segment2] }
        it { is_expected.to eq(path_instance) }
      end
    end

    context 'path does not exist' do
      let(:segment1) { Faker::Lorem.word }
      let(:segment2) { Faker::Lorem.word }
      subject { Path.find_path(path) }

      context 'passing a / seperated string' do
        let(:path) { "/#{segment1}/#{segment2}" }
        it { is_expected.to be_nil }
      end

      context 'passing an array of strings in hierarchy' do
        let(:path) { [segment1, segment2] }
        it { is_expected.to be_nil }
      end
    end
  end

  describe '::exists?' do
    context 'path exists' do
      let(:segment1) { Faker::Lorem.word }
      let(:segment2) { Faker::Lorem.word }
      let!(:path_instance) { Path.find_or_create_by_path([segment1, segment2]) }
      subject { Path.exists?(path) }

      context 'passing a / seperated string' do
        let(:path) { "/#{segment1}/#{segment2}" }
        it { is_expected.to be_truthy }
      end

      context 'passing an array of strings in hierarchy' do
        let(:path) { [segment1, segment2] }
        it { is_expected.to be_truthy }
      end
    end

    context 'path does not exist' do
      let(:segment1) { Faker::Lorem.word }
      let(:segment2) { Faker::Lorem.word }
      subject { Path.exists?(path) }

      context 'passing a / seperated string' do
        let(:path) { "/#{segment1}/#{segment2}" }
        it { is_expected.to be_falsey }
      end

      context 'passing an array of strings in hierarchy' do
        let(:path) { [segment1, segment2] }
        it { is_expected.to be_falsey }
      end
    end
  end

  describe '::routes?' do
    context 'path exists' do
      let(:segment1) { Faker::Lorem.word }
      let(:segment2) { Faker::Lorem.word }
      let!(:path_instance) { Path.find_or_create_by_path([segment1, segment2]) }
      subject { Path.routes?(path) }

      context 'has routable' do
        before { create(:standalone_product, path: path_instance) }

        context 'passing a / seperated string' do
          let(:path) { "/#{segment1}/#{segment2}" }
          it { is_expected.to be_truthy }
        end

        context 'passing an array of strings in hierarchy' do
          let(:path) { [segment1, segment2] }
          it { is_expected.to be_truthy }
        end
      end

      context 'does not have routable' do
        context 'passing a / seperated string' do
          let(:path) { "/#{segment1}/#{segment2}" }
          it { is_expected.to be_falsey }
        end

        context 'passing an array of strings in hierarchy' do
          let(:path) { [segment1, segment2] }
          it { is_expected.to be_falsey }
        end
      end
    end

    context 'path does not exist' do
      let(:segment1) { Faker::Lorem.word }
      let(:segment2) { Faker::Lorem.word }
      subject { Path.routes?(path) }

      context 'passing a / seperated string' do
        let(:path) { "/#{segment1}/#{segment2}" }
        it { is_expected.to be_falsey }
      end

      context 'passing an array of strings in hierarchy' do
        let(:path) { [segment1, segment2] }
        it { is_expected.to be_falsey }
      end
    end
  end
end
