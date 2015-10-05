module Publishing
  module Categories
    def categories
      return if Site.current.primary_categories.empty?

      FileUtils.mkdir_p(categories_path)

      Site.current.primary_categories.each do |c|
        next unless c.enabled?

        frontmatter = Jbuilder.encode do |json|
          category(json, c)
        end
        write_category(c, frontmatter)
      end
    end

    def categories_path
      paths = Rails.configuration.zepily.publishing.paths
      File.join(paths.base, Site.current.id.to_s, paths.categories)
    end

    def category(json, c)
      json.template 'category'
      json.format 'html'
      json.call(c, :id, :name, :description, :path)
      json.updated_at c.updated_at.iso8601
      category_optional_fields(json, c)
      category_members(json, c)
      subcategories(json, c.subcategories) unless c.subcategories.empty?
    end

    def category_optional_fields(json, c)
      optional_fields(json, c, [:tags, :metadata])
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
      json.category_members do
        json.array! c.category_members.sort_by(&:order) do |cm|
          category_member(json, cm) if cm.product.enabled?
        end
      end
    end

    def category_member(json, cm)
      product = cm.product
      json.call(cm, :id, :order)
      json.description(cm.description || product.description)
      category_member_product(json, product)
      category_member_image(json, cm)
    end

    def category_member_product(json, p)
      json.product do
        json.call(p, :name, :path, :currency, :weight)
        json.product_id p.id
        json.price_cents p.price.cents
        optional_fields(json, p, [:tags, :metadata])
      end
    end

    def category_member_image(json, cm)
      return unless cm.image_instance.present?

      json.image_instance do
        image_instance(json, cm.image_instance)
      end
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
