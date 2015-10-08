class Path < ActiveRecord::Base
  include ParentSite

  belongs_to :routable, polymorphic: true

  has_closure_tree name_column: 'segment', order: 'segment'
  has_paper_trail
  valhammer
end
