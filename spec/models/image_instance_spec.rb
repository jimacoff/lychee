require 'rails_helper'

RSpec.describe ImageInstance, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :image_instance }
  end
  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:imageable_type).of_type(:string) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }
    it { is_expected.to have_db_column(:order).of_type(:integer) }

    it 'should have non nullable column imageable_id of type bigint' do
      expect(subject).to have_db_column(:imageable_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index([:imageable_type, :imageable_id]) }
    it { is_expected.to have_db_index(:imageable_type) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:image).class_name('Image') }
    it { is_expected.to belong_to(:imageable) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :image }
    it { is_expected.to validate_presence_of :imageable }
    it { is_expected.to validate_presence_of :order }
  end

  context 'polymorphic relationships' do
    context 'category_member' do
      subject { create :image_instance, :for_product_category }
      it { is_expected.to be_valid }
    end

    context 'variation_instance' do
      subject { create :image_instance, :for_variation_instance }
      it { is_expected.to be_valid }
    end

    context 'product' do
      subject { create :image_instance, :for_product }
      it { is_expected.to be_valid }
    end

    context 'category' do
      subject { create :image_instance, :for_category }
      it { is_expected.to be_valid }
    end
  end

  describe '#name' do
    let(:name) { Faker::Lorem.word }
    subject { create :image_instance }

    it 'supplies local name if defined' do
      subject.name = name
      expect(subject.name).to eq(name)
      expect(subject.name).not_to eq(subject.image.name)
    end

    it 'supplies image name when undefined' do
      expect(subject.name).to eq(subject.image.name)
    end
  end

  describe '#description' do
    let(:description) { Faker::Lorem.paragraph }
    subject { create :image_instance }

    it 'supplies local description if defined' do
      subject.description = description
      expect(subject.description).to eq(description)
      expect(subject.description).not_to eq(subject.image.description)
    end

    it 'supplies image description when undefined' do
      expect(subject.description).to eq(subject.image.description)
    end
  end
end
