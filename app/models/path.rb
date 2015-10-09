class Path < ActiveRecord::Base
  include ParentSite

  belongs_to :routable, polymorphic: true

  has_closure_tree name_column: 'segment', order: 'segment', dependent: :nullify
  has_paper_trail
  valhammer

  class << self
    def exists?(path)
      find_by_path(path).present?
    end

    def routes?(path)
      p = find_by_path(path)
      p && p.routable.present?
    end

    def find_by_path(path, attributes = {}, parent_id = nil)
      return super unless path.is_a? String
      super(string_path_to_array(path), attributes, parent_id)
    end

    def find_or_create_by_path(path, attributes = {})
      return super unless path.is_a? String
      super(string_path_to_array(path), attributes)
    end

    def string_path_to_array(path)
      path.scan(%r{[^/]+})
    end
  end
end
