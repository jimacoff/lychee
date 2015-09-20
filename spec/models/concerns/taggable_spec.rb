require 'rails_helper'

RSpec.describe Taggable, site_scoped: true do
  before do
    Temping.create :taggable_model do
      include Taggable
      include ParentSite

      with_columns do |t|
        t.text :tags, array: true, default: []
        t.belongs_to :site, null: false
      end
    end
  end

  after { Temping.teardown }

  subject { TaggableModel.new }

  context 'manipulating tag data' do
    let(:tag) { Faker::Lorem.word }

    context 'addition' do
      before { expect(subject.tags).to be_empty }

      let(:run) { subject.add_tag(tag) }

      it 'stores data' do
        expect { run }.to change(subject, :tags).to include(tag)
      end

      it 'has #changed?' do
        expect { run }.to change(subject, :tags_changed?).to(true)
      end
    end

    context 'deletion' do
      let(:tag) { Faker::Lorem.word }
      subject { TaggableModel.new(tags: [tag]) }

      before { subject.save }
      let(:run) { subject.delete_tag(tag) }

      it 'deletes data' do
        expect { run }.to change(subject, :tags).to exclude(tag)
      end

      it 'has #changed?' do
        expect { run }.to change(subject, :tags_changed?).to(true)
      end
    end
  end

  context 'querying tagged objects' do
    before :example do
      @tag1 = "#{Faker::Lorem.word}_#{Faker::Number.number(4)}"
      @tag2 = "#{Faker::Lorem.word}_#{Faker::Number.number(4)}"
      @tag3 = "#{Faker::Lorem.word}_#{Faker::Number.number(4)}"
      @tag4 = "#{Faker::Lorem.word}_#{Faker::Number.number(4)}"

      @obj1 = TaggableModel.create tags: [@tag1]
      @obj2 = TaggableModel.create tags: [@tag2, @tag3, @tag4]
      @obj3 = TaggableModel.create tags: [@tag3, @tag4]
    end

    def fake_tag
      "_#{Faker::Lorem.word}"
    end

    context '#all_tags' do
      def all(tags)
        TaggableModel.all_tags tags
      end
      context 'search on single tag' do
        it 'does not match' do
          expect(all fake_tag).to be_empty
        end
        it 'matches one' do
          expect(all @tag1).to contain_exactly(@obj1)
        end
        it 'matches multiple' do
          expect(all @tag3).to contain_exactly(@obj2, @obj3)
        end
      end

      context 'search on multiple tags' do
        it 'does not match' do
          expect(all [fake_tag, fake_tag]).to be_empty
        end
        it 'matches one' do
          expect(all [@tag2, @tag3]).to contain_exactly(@obj2)
        end
        it 'matches multiple' do
          expect(all [@tag3, @tag4]).to contain_exactly(@obj2, @obj3)
        end
      end
    end

    context '#any_tag' do
      def any(tags)
        TaggableModel.any_tag tags
      end
      context 'search on single tag' do
        it 'does not match' do
          expect(any fake_tag).to be_empty
        end
        it 'matches one' do
          expect(any @tag1).to contain_exactly(@obj1)
        end
        it 'matches multiple' do
          expect(any @tag3).to contain_exactly(@obj2, @obj3)
        end
      end

      context 'search on multiple tags' do
        it 'does not match' do
          expect(any [fake_tag, fake_tag]).to be_empty
        end
        it 'matches one' do
          expect(any [@tag1, fake_tag]).to contain_exactly(@obj1)
        end
        it 'matches multiple' do
          expect(any [@tag2, @tag3, @tag4]).to contain_exactly(@obj2, @obj3)
        end
      end
    end
  end
end
