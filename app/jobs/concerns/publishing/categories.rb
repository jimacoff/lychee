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
      optional_fields(json, c)
      category_members(json, c)
      subcategories(json, c.subcategories) unless c.subcategories.empty?
    end

    def optional_fields(json, c)
      json.tags c.tags unless c.tags.empty?
      json.metadata c.metadata if c.metadata
      json.parent c.parent_category.id if c.parent_category
    end

    def category_members(_json, _c)
    end

    def subcategories(json, subcategories)
      json.subcategories do
        json.array! subcategories do |sc|
          category(json, sc) if sc.enabled?
        end
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
