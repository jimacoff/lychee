class ProductVersion < PaperTrail::Version
  self.table_name = :product_versions
  self.sequence_name = :product_version_id_seq
end
