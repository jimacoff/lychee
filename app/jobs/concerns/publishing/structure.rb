module Publishing
  module Structure
    def site_structure
      FileUtils.mkdir_p(structure_path)
      json = Jbuilder.encode { |j| structure(j) }
      structure_write(json)
    end

    def structure(json)
      s = Site.current
      json.call(s, :id, :name)
      currency(json, s.currency)
      preferences(json, s.preferences)

      structure_categories(json, s.primary_categories)
      structure_products(json, s.products)
      structure_images(json, s.images)
    end

    def structure_path
      paths = Rails.configuration.zepily.publishing.paths
      File.join(paths.base, Site.current.id.to_s)
    end

    def currency(json, cur)
      json.currency do
        json.call(cur, :decimal_mark, :iso_code, :iso_numeric, :name,
                  :priority, :subunit, :subunit_to_unit, :symbol,
                  :symbol_first, :thousands_separator)
      end
    end

    def preferences(json, p)
      json.preferences do
        json.call(p, :tax_basis, :prices_include_tax,
                  :order_subtotal_include_tax, :reserved_uri_paths)
        optional_fields(json, p, [:metadata])
      end
    end

    def structure_categories(json, categories)
      json.categories do
        json.array! categories.each do |c|
          next unless c.routable?

          category(json, c)
        end
      end
    end

    def structure_products(json, products)
      json.products do
        json.array! products.each do |p|
          next unless p.routable?

          product(json, p)
        end
      end
    end

    def structure_images(json, images)
      json.images do
        json.array! images.each do |i|
          next unless i.routable?
          image(json, i)
        end
      end
    end

    def structure_write(json)
      File.open(File.join(structure_path, 'site_structure.json'), 'w') do |f|
        f.puts json
      end
    end
  end
end
