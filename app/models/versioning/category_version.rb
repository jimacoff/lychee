module Versioning
  class CategoryVersion < PaperTrail::Version
    self.table_name = :category_versions
    self.sequence_name = :category_version_id_seq
  end
end
