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
  has_context 'geographic hierarchy' do
    let(:factory) { :tax_rate }
  end
  has_context 'geographic hierarchy conversion' do
    let(:factory) { :tax_rate }
  end
  has_context 'enablement' do
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
          expect(new_rate.errors[:geographic_hierarchy].size).to eq(1)
        end

        it 'creates new tax record when duplicate but different parent site' do
          expect(new_rate_alt_site).to be_valid
        end
      end
    end
  end

  context 'scopes' do
    describe 'required_for_location' do
      let(:au) { create :country, iso_alpha2: 'au' }
      let(:nz) { create :country, iso_alpha2: 'nz' }

      let(:qld) { create :state, iso_code: 'qld', country: au }
      let(:nsw) { create :state, iso_code: 'nsw', country: au }

      let(:tax_category1) { create :tax_category }
      let(:tax_category2) { create :tax_category }

      let!(:tr1) do
        create :tax_rate, priority: 1, country: au, tax_category: tax_category1
      end
      let!(:tr2) do
        create :tax_rate, priority: 1, country: au, state: qld,
                          tax_category: tax_category1
      end
      let!(:tr3) do
        create :tax_rate, priority: 1, country: au, state: qld,
                          postcode: '4000', tax_category: tax_category1
      end
      let!(:tr4) do
        create :tax_rate, priority: 2, country: au, tax_category: tax_category1
      end
      let!(:tr5) do
        create :tax_rate, priority: 11, country: au, state: qld,
                          tax_category: tax_category1
      end
      let!(:tr6) do
        create :tax_rate, priority: 999, country: au, state: qld,
                          postcode: '4000', tax_category: tax_category1
      end
      let!(:tr7) do
        create :tax_rate, priority: 1_000, country: au, state: qld,
                          postcode: '4000', locality: 'Brisbane',
                          tax_category: tax_category1
      end
      let!(:tr8) do # overload priority 2 for Brisbane locations only
        create :tax_rate, priority: 2, country: au, state: qld,
                          postcode: '4000', locality: 'Brisbane',
                          tax_category: tax_category1
      end
      let!(:tr9) do
        create :tax_rate, priority: 999, country: au, state: qld,
                          postcode: '4000', locality: 'Brisbane',
                          tax_category: tax_category2
      end
      let!(:tr10) do # disabled tax rate should not appear anywhere
        create :tax_rate, priority: 3, country: au, enabled: false,
                          tax_category: tax_category1
      end

      context 'correct taxes for locations in category 1' do
        it 'retrieves au.qld.4000' do
          expect(TaxRate.required_for_location('au.qld.4000',
                                               tax_category1))
            .to contain_exactly(tr3, tr4, tr5, tr6)
        end
        it 'retrieves au.qld.4000.brisbane' do
          expect(TaxRate.required_for_location('au.qld.4000.brisbane',
                                               tax_category1))
            .to contain_exactly(tr3, tr5, tr6, tr7, tr8)
        end
        it 'retrieves au.qld.4005' do
          expect(TaxRate.required_for_location('au.qld.4005', tax_category1))
            .to contain_exactly(tr2, tr4, tr5)
        end
        it 'retrieves au.qld.4005.newfarm' do
          expect(TaxRate.required_for_location('au.qld.4005.newfarm',
                                               tax_category1))
            .to contain_exactly(tr2, tr4, tr5)
        end
        it 'retrieves au.nsw.2000.sydney' do
          expect(TaxRate.required_for_location('au.nsw.2000.sydney',
                                               tax_category1))
            .to contain_exactly(tr1, tr4)
        end
        it 'retrieves au.vic' do
          expect(TaxRate.required_for_location('au.nsw.2000.sydney',
                                               tax_category1))
            .to contain_exactly(tr1, tr4)
        end
        it 'retrieves us.california' do
          expect(TaxRate.required_for_location('us.california',
                                               tax_category1))
            .to be_empty
        end
      end
      context 'correct taxes for locations in category 2' do
        it 'retrieves au.qld.4000' do
          expect(TaxRate.required_for_location('au.qld.4000',
                                               tax_category2))
            .to be_empty
        end
        it 'retrieves au.qld.4000.brisbane' do
          expect(TaxRate.required_for_location('au.qld.4000.brisbane',
                                               tax_category2))
            .to contain_exactly(tr9)
        end
        it 'retrieves au.qld.4005' do
          expect(TaxRate.required_for_location('au.qld.4005', tax_category2))
            .to be_empty
        end
        it 'retrieves au.qld.4005.newfarm' do
          expect(TaxRate.required_for_location('au.qld.4005.newfarm',
                                               tax_category2))
            .to be_empty
        end
        it 'retrieves au.nsw.2000.sydney' do
          expect(TaxRate.required_for_location('au.nsw.2000.sydney',
                                               tax_category2))
            .to be_empty
        end
        it 'retrieves au.vic' do
          expect(TaxRate.required_for_location('au.nsw.2000.sydney',
                                               tax_category2))
            .to be_empty
        end
      end
    end
  end
end
