class CategoryMember < ActiveRecord::Base
  has_paper_trail

  include ParentSite

  belongs_to :category
  belongs_to :product
  belongs_to :variant

  validates :category, presence: true
  validate :validate_members

  def validate_members
    members = [:product, :variant]
    member_instances = members.map { |member| send(member) }.compact
    return if member_instances.one?

    if member_instances.none?
      errors.add(:base, "Must be owned by one of #{members.join(', ')}")
    else
      errors.add(:base, 'Cannot be owned by more then one of' \
                             " #{members.join(', ')}")
    end
  end
end
