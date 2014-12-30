class Trait < ActiveRecord::Base
  include Taggable
  include Metadata

  belongs_to :parent, class_name: 'Trait'
  has_one :subtrait, class_name: 'Trait', foreign_key: 'parent_id'

  validates :name, presence: true
  validates :display_name, presence: true

  def add_default_value(value)
    default_values_will_change!
    default_values.push value
  end

  def delete_default_value(value)
    default_values_will_change!
    default_values.delete value
  end
end
