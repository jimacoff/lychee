require 'rails_helper'

RSpec.describe Preference, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :preference }
  end

  has_context 'versioned'
  has_context 'metadata'

  context 'table structure' do
    it { is_expected.to have_db_column(:prices_include_tax).of_type(:boolean) }
    it { is_expected.to have_db_column(:tax_basis).of_type(:integer) }
    it do
      is_expected.to have_db_column(:order_subtotal_include_tax)
        .of_type(:boolean)
    end
    it { is_expected.to have_db_column(:reserved_uri_paths).of_type(:hstore) }

    it { is_expected.to have_db_column(:bag_title).of_type(:string) }
    it { is_expected.to have_db_column(:bag_flash).of_type(:string) }
    it { is_expected.to have_db_column(:bag_summary_notice).of_type(:string) }
    it { is_expected.to have_db_column(:bag_shipping_notice).of_type(:string) }
    it do
      is_expected
        .to have_db_column(:bag_action_continue_shopping).of_type(:string)
    end
    it { is_expected.to have_db_column(:bag_action_checkout).of_type(:string) }
    it { is_expected.to have_db_column(:bag_empty_notice).of_type(:string) }
    it do
      is_expected
        .to have_db_column(:bag_empty_start_shopping).of_type(:string)
    end

    it 'should have non nullable column site_id of type bigint' do
      expect(subject).to have_db_column(:site_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:site_id) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:site).class_name('Site') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :tax_basis }

    it { is_expected.to validate_presence_of :bag_title }
    it { is_expected.to validate_presence_of :bag_flash }
    it { is_expected.to validate_presence_of :bag_summary_notice }
    it { is_expected.to validate_presence_of :bag_action_continue_shopping }
    it { is_expected.to validate_presence_of :bag_action_checkout }
    it { is_expected.to validate_presence_of :bag_empty_notice }
    it { is_expected.to validate_presence_of :bag_empty_start_shopping }

    it 'stores an enum for taxation calculations basis' do
      expect(subject).to define_enum_for(:tax_basis)
        .with([:delivery, :customer, :subscriber])
    end

    context 'instance validations' do
      subject { create :preference }
      it { is_expected.to be_valid }

      it 'is invalid for order subtotal not incl tax when prices incl tax' do
        subject.prices_include_tax = true
        subject.order_subtotal_include_tax = false
        expect(subject).to be_invalid
      end

      it 'is valid for order subtotal not incl tax when prices not incl tax' do
        subject.prices_include_tax = false
        subject.order_subtotal_include_tax = false
        expect(subject).to be_valid
      end

      Preference::REQUIRED_RESERVED_URI_PATHS.each do |path|
        it "is invalid without #{path} reserved path" do
          subject.reserved_uri_paths.delete(path)
          expect(subject).to be_invalid
        end
      end

      it 'is invalid with duplicate reserved paths' do
        subject.reserved_uri_paths['blog'] =
          subject.reserved_uri_paths['blog_tags']
        expect(subject).to be_invalid
      end

      it 'is invalid with reserved paths that are not marked required' do
        subject.reserved_uri_paths['x'] = "/#{Faker::Internet.slug}"
        expect(subject).to be_invalid
      end

      it 'requires a fixed shopping_bag path' do
        subject.reserved_uri_paths['shopping_bag'] = '/x'
        expect(subject).to be_invalid
      end
    end
  end

  describe '#reserved_uri_path(key)' do
    subject { create :preference }

    context 'with a valid key' do
      let(:reserved_path) { subject.reserved_uri_paths.first }
      let(:key) { reserved_path[0] }
      let(:expected_path) { reserved_path[1] }
      it 'provides a hierarchical path representation as array' do
        expect(subject.reserved_uri_path(key)).to eq(expected_path)
      end
    end

    context 'with an invalid key' do
      let(:key) { Faker::Lorem.word }
      it 'is nil' do
        expect(subject.reserved_uri_path(key)).to be_nil
      end
    end
  end
end
