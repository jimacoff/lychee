require 'rails_helper'

<% module_namespacing do -%>
RSpec.describe <%= class_name %>, <%= type_metatag(:model) %>, site_scoped: true do
  has_context 'parent site' do
    let(:factory) { :<%= class_name.downcase %> }
  end
  # Add additonal shared contexts

  context 'table structure' do
    # TODO
    # it { is_expected.to have_db_column(:xyz).of_type(:xyz) }
  end

  context 'relationships' do
    # TODO
    # it { is_expected.to have_many :xyz }
    # it { is_expected.to have_one :abc }
  end

  context 'validations' do
    # TODO
    # it { is_expected.to validate_presence_of :xyz }

    context 'instance validations' do
      # TODO
      # subject { create :<%= class_name.downcase.to_sym %> }
    end
  end
end
<% end -%>
