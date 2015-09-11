module Publishing
  module Categories
    def categories
      return if @site.primary_categories.empty?

      FileUtils.mkdir_p(categories_path)

      @site.primary_categories.each do |c|
        next unless c.enabled?

        frontmatter = Jbuilder.encode do |json|
          category(json, c)
        end
        write_category(c, frontmatter)
      end
    end

    def categories_path
      paths = Rails.configuration.zepily.publishing.paths
      File.join(paths.base, @site.id.to_s, paths.categories)
    end

    def category(json, c)
      json.call(c, :id, :name, :description, :path)
      json.updated_at c.updated_at.iso8601
      category_optional_fields(json, c)
      category_members(json, c)
      subcategories(json, c.subcategories) unless c.subcategories.empty?
    end

    def category_optional_fields(json, c)
      json.tags c.tags unless c.tags.empty?
      json.metadata c.metadata if c.metadata
      json.parent c.parent_category.id if c.parent_category
    end

    def subcategories(json, subcategories)
      json.subcategories do
        json.array! subcategories do |sc|
          category(json, sc) if sc.enabled?
        end
      end
    end

    def category_members(json, c)
      json.products do
        json.array! c.category_members do |cm|
          category_member(json, cm) if cm.product.enabled?
        end
      end
    end

    def category_member(json, cm)
      p = cm.product
      json.id cm.id
      json.call(p, :name, :slug, :currency, :weight)
      json.product_id p.id
      json.price_cents p.price.cents
      json.description(cm.description || p.description)

      category_member_image(json, cm)
      category_member_optional_fields(json, cm, p)
    end

    def category_member_image(json, cm)
      image_instance(json, cm.image_instance) if cm.image_instance.present?
    end

    def category_member_optional_fields(json, _cm, p)
      json.tags p.tags unless p.tags.empty?
      json.metadata p.metadata if p.metadata
    end

    def write_category(c, frontmatter)
      File.open(File.join(categories_path, "#{c.id}.json"), 'w') do |f|
        f.puts PublishSiteJob::START_JSON_DELIMITER
        f.puts frontmatter
        f.puts PublishSiteJob::END_JSON_DELIMITER
      end
    end
  end
end
