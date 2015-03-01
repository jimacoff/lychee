require 'rails_helper'

<% module_namespacing do -%>
RSpec.describe <%= class_name %>, <%= type_metatag(:model) %> do
  has_context 'parent site' do
    let(:factory) { specify factory_girl model }
  end
  # Add additonal shared contexts

  context 'table structure' do
    # TODO
  end

  context 'relationships' do
    # TODO
  end

  context 'validations' do
    # TODO

    context 'instance validations' do
      # TODO
    end
  end
end
<% end -%>
