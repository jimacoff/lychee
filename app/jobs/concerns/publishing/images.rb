module Publishing
  module Images
    def image_instance(json, ii)
      json.call(ii, :id)
      json.image do
        image(json, ii.image)
      end
      image_instance_optional_fields(json, ii)
    end

    def image_instance_optional_fields(json, ii)
      json.metadata ii.metadata if ii.metadata
    end

    def image(json, img)
      json.call(img, :id, :name, :description, :internal_name, :extension)
      image_optional_fields(json, img)
      json.default_image do
        image_file(json, img.image_files.default_image)
      end
      json.original_image do
        image_file(json, img.image_files.original_image)
      end
      image_srcset(json, img)
    end

    def image_optional_fields(json, img)
      json.tags img.tags unless img.tags.empty?
      json.metadata img.metadata if img.metadata
    end

    def image_srcset(json, img)
      json.srcset do
        json.array! img.image_files.srcset do |img_file|
          image_file(json, img_file)
        end
      end
    end

    def image_file(json, img_file)
      json.call(img_file, :id, :filename, :width)
      json.height img_file.height if img_file.height
      json.x_dimension img_file.x_dimension if img_file.x_dimension
      image_file_optional_fields(json, img_file)
    end

    def image_file_optional_fields(json, img_file)
      json.metadata img_file.metadata if img_file.metadata
    end
  end
end