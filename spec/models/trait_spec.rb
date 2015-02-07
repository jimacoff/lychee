require 'rails_helper'

RSpec.describe Trait, type: :model do
  has_context 'versioned'
  has_context 'taggable'
  has_context 'metadata'
  has_context 'parent site'

  context 'table structure' do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:display_name).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :display_name }
  end

  context 'default values' do
    subject { create :trait }
    let(:value) { Faker::Lorem.word }

    it 'is valid without default values being specified' do
      expect(subject).to be_valid
    end

    context '#add_default_values' do
      def add(v)
        subject.add_default_value v
      end
      it 'stores a value' do
        expect { add value }.to change(subject, :default_values)
          .to contain_exactly(value)
      end
      it 'has #changed?' do
        expect { add value }.to change(subject, :default_values_changed?)
          .to(true)
      end
    end

    context '#delete_default_value' do
      subject { create :trait, default_values: [value] }
      def del(v)
        subject.delete_default_value v
      end

      it 'deletes a value' do
        expect { del value }.to change(subject, :default_values)
          .to be_empty
      end
      it 'has #changed?' do
        expect { del value }.to change(subject, :default_values_changed?)
          .to(true)
      end
    end
  end
end
