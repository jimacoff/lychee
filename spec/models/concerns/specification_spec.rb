require 'rails_helper'
require 'json'

RSpec.describe Specification do
  before do
    Temping.create :specification_model do
      include Specification

      with_columns do |t|
        t.json :specifications
      end
    end
  end

  after { Temping.teardown }

  subject { SpecificationModel.new }

  # Number of categories(cats), values per category(vals)
  # and subcategories(subs)
  #
  # Additionally should subcategories randomly define their own
  # subcategories(subsub) and should values only be populated in the
  # lowest level subcategory or in all intermediate subcategories (leaves)
  #
  # Resultant JSON built by this recursion should be compliant to the JSON
  # schema developed for specifications
  def categories(cats, vals, subs, subsub = false, leaves = false)
    { categories:
      (0...cats).map do
        category(vals, subs, subsub, leaves)
      end
    }
  end

  def category(vals, subs, subsub, leaves)
    category = { name: Faker::Lorem.word }
    category['values'] = values(vals) if vals > 0
    category['subcategories'] = subcategories(subs, subsub, leaves) if subs > 0
    category
  end

  def values(vals)
    return [] unless vals > 0

    values = values(vals - 1)
    values << { name: Faker::Lorem.word, value: Faker::Lorem.word }
  end

  def subcategories(subs, subsub, leaves)
    return [] unless subs > 0

    subcategories = subcategories(subs - 1, subsub, leaves)

    subcategory = { name: Faker::Lorem.word }
    subcategory['values'] = values(2) unless leaves
    subcategory['subcategories'] = subcategories(1, false, false) if subsub

    subcategories << subcategory
  end

  it { is_expected.to be_valid } # nil specifications

  it 'must specify categories' do
    subject.specifications = {}
    expect(subject).not_to be_valid
  end

  it 'must specify data for at least one category' do
    subject.specifications = { categories: [] }
    expect(subject).not_to be_valid
  end

  RSpec.shared_examples 'a specification' do
    context 'allows a single value' do
      let(:value_count) { 1 }
      before do
        subject.specifications = categories(category_count, value_count, 0)
      end

      it { is_expected.to be_valid }
      it 'has all required categories' do
        expect(subject.specifications['categories'].size).to eq(category_count)
      end
      it 'has category values' do
        subject.specifications['categories'].each do |cat|
          expect(cat['values'].size).to eq(value_count)
        end
      end
      it 'has no subcategories' do
        expect(subject.specifications['categories'][0]['subcategories'])
          .to be_nil
      end
    end

    context 'allows multiple values' do
      let(:value_count) { Random.rand(2..5) }
      before do
        subject.specifications = categories(category_count, value_count, 0)
      end

      it { is_expected.to be_valid }
      it 'has all required categories' do
        expect(subject.specifications['categories'].size).to eq(category_count)
      end
      it 'has category values' do
        subject.specifications['categories'].each do |cat|
          expect(cat['values'].size).to eq(value_count)
        end
      end
      it 'has no subcategories' do
        expect(subject.specifications['categories'][0]['subcategories'])
          .to be_nil
      end
    end

    context 'allows a single subcategory' do
      let(:value_count) { 0 }
      let(:subcategory_count) { 1 }
      before do
        subject.specifications =
          categories(category_count, value_count, subcategory_count)
      end

      it { is_expected.to be_valid }
      it 'has all required categories' do
        expect(subject.specifications['categories'].size).to eq(category_count)
      end
      it 'has no category values' do
        subject.specifications['categories'].each do |cat|
          expect(cat['values']).to be_nil
        end
      end
      it 'has 1 subcategory per category' do
        subject.specifications['categories'].each do |cat|
          expect(cat['subcategories'].size).to eq(1)
        end
      end
    end

    context 'allows multiple subcategories' do
      let(:value_count) { 0 }
      let(:subcategory_count) { Random.rand(2..5) }
      before do
        subject.specifications =
          categories(category_count, value_count, subcategory_count)
      end

      it { is_expected.to be_valid }

      it 'has all required categories' do
        expect(subject.specifications['categories'].size).to eq(category_count)
      end

      it 'has no category values' do
        subject.specifications['categories'].each do |cat|
          expect(cat['values']).to be_nil
        end
      end

      context 'subcategories' do
        it 'has multple instances' do
          subject.specifications['categories'].each do |cat|
            expect(cat['subcategories'].size).to eq(subcategory_count)
          end
        end

        it 'has values' do
          subject.specifications['categories'].each do |cat|
            cat['subcategories'].each do |subcat|
              expect(subcat['values'].size).to be > 1
            end
          end
        end

        it 'has no further subcategories' do
          subject.specifications['categories'].each do |cat|
            expect(cat['subcategories'][0]['subcategories']).to be_nil
          end
        end
      end
    end

    context 'allows multiple subcategories having subcategories' do
      let(:value_count) { 0 }
      let(:subcategory_count) { Random.rand(2..5) }
      before do
        subject.specifications =
          categories(category_count, value_count, subcategory_count, true)
      end

      it { is_expected.to be_valid }

      it 'has all required categories' do
        expect(subject.specifications['categories'].size).to eq(category_count)
      end

      it 'has no category values' do
        subject.specifications['categories'].each do |cat|
          expect(cat['values']).to be_nil
        end
      end

      context 'subcategories' do
        it 'has multple instances' do
          subject.specifications['categories'].each do |cat|
            expect(cat['subcategories'].size).to eq(subcategory_count)
          end
        end

        it 'has values' do
          subject.specifications['categories'].each do |cat|
            cat['subcategories'].each do |subcat|
              expect(subcat['values'].size).to be > 1
            end
          end
        end

        it 'each subcategory has further subcategories' do
          subject.specifications['categories'].each do |cat|
            cat['subcategories'].each do |subcat|
              expect(subcat['subcategories'].size).to be > 0
            end
          end
        end
      end
    end

    context 'allows subcategories with values everywhere' do
      let(:value_count) { Random.rand(2..5) }
      let(:subcategory_count) { Random.rand(2..5) }
      before do
        subject.specifications =
          categories(category_count, value_count, subcategory_count, true)
      end

      it { is_expected.to be_valid }

      it 'has all required categories' do
        expect(subject.specifications['categories'].size).to eq(category_count)
      end

      it 'has category values' do
        subject.specifications['categories'].each do |cat|
          expect(cat['values'].size).to eq(value_count)
        end
      end

      context 'subcategories' do
        it 'has multple instances' do
          subject.specifications['categories'].each do |cat|
            expect(cat['subcategories'].size).to eq(subcategory_count)
          end
        end

        it 'has values' do
          subject.specifications['categories'].each do |cat|
            cat['subcategories'].each do |subcat|
              expect(subcat['values'].size).to be > 1
            end
          end
        end

        it 'each subcategory has further subcategories' do
          subject.specifications['categories'].each do |cat|
            cat['subcategories'].each do |subcat|
              expect(subcat['subcategories'].size).to be > 0
            end
          end
        end
      end
    end

    context 'allows subcategories with values only in leaves' do
      let(:value_count) { 0 }
      let(:subcategory_count) { Random.rand(2..5) }
      before do
        subject.specifications =
          categories(category_count, value_count, subcategory_count, true, true)
      end

      it { is_expected.to be_valid }

      it 'has all required categories' do
        expect(subject.specifications['categories'].size).to eq(category_count)
      end

      it 'has no category values' do
        subject.specifications['categories'].each do |cat|
          expect(cat['values']).to be_nil
        end
      end

      context 'subcategories' do
        it 'has multple instances' do
          subject.specifications['categories'].each do |cat|
            expect(cat['subcategories'].size).to eq(subcategory_count)
          end
        end

        it 'has no values' do
          subject.specifications['categories'].each do |cat|
            cat['subcategories'].each do |subcat|
              expect(subcat['values']).to be_nil
            end
          end
        end

        it 'each subcategory has further subcategories' do
          subject.specifications['categories'].each do |cat|
            cat['subcategories'].each do |subcat|
              expect(subcat['subcategories'].size).to be > 0
            end
          end
        end

        it 'leaf subcategories have values' do
          subject.specifications['categories'].each do |cat|
            cat['subcategories'].each do |subcat|
              subcat['subcategories'].each do |subsubcat|
                expect(subsubcat['values'].size).to be > 0
              end
            end
          end
        end
      end
    end
  end

  context 'specifying a single top-level category' do
    include_examples 'a specification' do
      let(:category_count) { 1 }
    end
  end

  context 'specifying multiple top-level categories' do
    include_examples 'a specification' do
      let(:category_count) { 3 }
    end
  end
end
