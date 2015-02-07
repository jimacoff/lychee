require 'rails_helper'

RSpec.describe CategoryMember, type: :model, site_scoped: true do
  has_context 'parent site'

  has_context 'versioned'

  context 'validations' do
    it { is_expected.to validate_presence_of(:category) }

    context 'instance validations' do
      let(:category) { create :category }
      let(:product) { create :product }
      let(:variant) { create :variant }
      subject { build(:category_member, category: category) }

      it 'is invalid if both product and variant are populated' do
        subject.product = product
        subject.variant = variant
        expect(subject).not_to be_valid
      end

      it 'is invalid if neither product or variant are populated' do
        expect(subject).not_to be_valid
      end

      it 'is valid if only product is populated' do
        subject.product = product
        expect(subject).to be_valid
      end

      it 'is valid if only variant is populated' do
        subject.variant = variant
        expect(subject).to be_valid
      end
    end
  end
end
