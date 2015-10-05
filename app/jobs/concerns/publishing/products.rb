module Publishing
  module Products
    def products
      return if Site.current.products.empty?

      FileUtils.mkdir_p(products_path)

      Site.current.products.each do |p|
        next unless p.enabled?

        frontmatter = Jbuilder.encode do |json|
          product(json, p)
        end
        write_product(p, frontmatter)
      end
    end

    def products_path
      paths = Rails.configuration.zepily.publishing.paths
      File.join(paths.base, Site.current.id.to_s, paths.products)
    end

    def product(json, p)
      json.template 'product'
      json.format p.markup_format
      json.call(p, :id, :name, :description, :path,
                :price_cents, :currency, :weight)
      json.updated_at p.updated_at.iso8601
      product_optional_fields(json, p)
    end

    def product_optional_fields(json, p)
      optional_fields(json, p, [:tags, :metadata, :gtin, :sku, :specifications])
      product_images(json, p.image_instances) if p.images.present?
      product_variations(json, p.variations) if p.variations.present?
      product_categories(json, p.categories) if p.categories.present?
    end

    def product_images(json, image_instances)
      json.image_instances do
        json.array! image_instances.sort_by(&:order) do |ii|
          image_instance(json, ii)
        end
      end
    end

    def product_variations(json, variations)
      json.variations do
        json.array! variations.sort_by(&:order) do |var|
          product_variation(json, var)
        end
      end
    end

    def product_variation(json, var)
      json.call(var, :id, :order, :render_as)
      variation_trait(json, var.trait)
      json.values do
        json.array! var.variation_values do |vi|
          variation_value(json, vi)
        end
      end
      optional_fields(json, var, [:metadata])
    end

    def variation_trait(json, t)
      json.trait do
        json.id t.id
        json.name t.name
        json.display_name t.display_name
        json.description t.description
      end
    end

    def variation_value(json, vv)
      json.id vv.id
      json.name vv.name
      json.description vv.description

      return unless vv.image_instance.present?
      json.image_instance image_instance(json, vv.image_instance)
    end

    def product_categories(json, categories)
      json.categories do
        json.array! categories do |cat|
          next unless cat.enabled?

          json.id cat.id
          json.name cat.name
          json.description cat.description
          json.path cat.path
        end
      end
    end

    def write_product(p, frontmatter)
      File.open(File.join(products_path, "#{p.id}.html"), 'w') do |f|
        f.puts PublishSiteJob::START_JSON_DELIMITER
        f.puts frontmatter
        f.puts PublishSiteJob::END_JSON_DELIMITER
        f.puts "\n#{p.markup}"
      end
    end
  end
end
