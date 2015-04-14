require 'rails_helper'

<% module_namespacing do -%>
RSpec.describe <%= class_name %>, <%= type_metatag(:model) %>, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :<%= class_name.underscore.to_sym %> }
  end
  has_context 'versioned'
  # Add additonal shared contexts

  context 'table structure' do
    # TODO
    # it { is_expected.to have_db_column(:xyz).of_type(:xyz) }
    #
    # references/belongs_to
    # it 'should have non nullable column xyz_id of type bigint' do
    #   expect(subject).to have_db_column(:xyz_id)
    #     .of_type(:integer)
    #     .with_options(limit: 8, null: true)
    # end
    # it { is_expected.to have_db_index(:xyz_id) }
  end

  context 'relationships' do
    # TODO
    # it { is_expected.to have_many :xyz }
    # it { is_expected.to have_one :xyz }
    # it { is_expected.to belong_to(:xyz).class_name('Xyz') }
  end

  context 'validations' do
    # TODO
    # it { is_expected.to validate_presence_of :xyz }

    context 'instance validations' do
      # TODO
      # subject { create :<%= class_name.underscore.to_sym %> }
    end
  end
end
<% end -%>
