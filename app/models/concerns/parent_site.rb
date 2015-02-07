module ParentSite
  extend ActiveSupport::Concern

  included do
    belongs_to :site
    validates :site, presence: true
    default_scope { where(site: Site.current) }
  end
end
