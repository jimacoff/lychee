require 'rails_helper'

RSpec.describe TaxRate, type: :model, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :tax_rate }
  end
  has_context 'parent country' do
    let(:factory) { :tax_rate }
  end
  has_context 'parent state' do
    let(:factory) { :tax_rate }
  end
  has_context 'hierarchy' do
    let(:factory) { :tax_rate }
  end
  has_context 'metadata'
  has_context 'versioned'

  context 'table structure' do
    it 'should have non nullable column tax_category_id of type bigint' do
      expect(subject).to have_db_column(:tax_category_id)
        .of_type(:integer)
        .with_options(limit: 8, null: false)
    end
    it { is_expected.to have_db_index(:tax_category_id) }

    it { is_expected.to have_db_column(:rate).of_type(:decimal) }

    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:string) }
    it { is_expected.to have_db_column(:invoice_note).of_type(:string) }

    it { is_expected.to have_db_column(:shipping).of_type(:boolean) }

    it { is_expected.to have_db_column(:priority).of_type(:integer) }
  end

  context 'relationships' do
    it { is_expected.to belong_to(:tax_category).class_name('TaxCategory') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :tax_category }

    it { is_expected.to validate_presence_of :rate }

    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :description }

    it { is_expected.to validate_presence_of :priority }

    context 'instance validations' do
      subject { create :tax_rate }

      context 'rate' do
        it 'must be greater that or equal to 0' do
          expect(subject).to validate_numericality_of(:rate)
            .is_greater_than_or_equal_to(0.0)
        end
        it 'must be less than or equal to 0' do
          expect(subject).to validate_numericality_of(:rate)
            .is_less_than_or_equal_to(1.0)
        end
      end

      context 'hierarchy per priority' do
        let(:new_rate) do
          build :tax_rate, country: subject.country, priority: subject.priority
        end
        let(:new_rate_alt_site) do
          build :tax_rate, site: create(:site),
                           country: subject.country,
                           priority: subject.priority
        end
        it 'fails to create new tax record when duplicate' do
          new_rate.valid?
          expect(new_rate.errors.size).to eq(1)
          expect(new_rate.errors[:hierarchy].size).to eq(1)
        end

        it 'creates new tax record when duplicate but different parent site' do
          expect(new_rate_alt_site).to be_valid
        end
      end
    end
  end
end
