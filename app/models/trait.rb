class Trait < ActiveRecord::Base
  include ParentSite
  include Taggable
  include Metadata

  has_paper_trail
  valhammer

  def add_default_value(value)
    default_values_will_change!
    default_values.push value
  end

  def delete_default_value(value)
    default_values_will_change!
    default_values.delete value
  end
end
