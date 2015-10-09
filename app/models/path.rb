class Path < ActiveRecord::Base
  include ParentSite

  belongs_to :routable, polymorphic: true

  has_closure_tree name_column: 'segment', order: 'segment'
  has_paper_trail
  valhammer

  def self.exists?(path)
    find_by_path(path).present?
  end

  def self.routes?(path)
    p = find_by_path(path)
    p && p.routable.present?
  end

  def self.find_by_path(path, attributes = {}, parent_id = nil)
    return super(path.scan(%r{[^/]+})) if path.is_a? String
    super
  end
end
