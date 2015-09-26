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
        json.array! img.image_files.srcset do |image_file|
          image_file(json, image_file, srcset_path: true)
        end
      end
    end

    def image_file(json, image_file, srcset_path: false)
      json.call(image_file, :id, :filename, :width, :height, :path)
      json.srcset_path image_file.srcset_path if srcset_path
      json.x_dimension image_file.x_dimension if image_file.x_dimension
      image_file_optional_fields(json, image_file)
    end

    def image_file_optional_fields(json, image_file)
      json.metadata image_file.metadata if image_file.metadata
    end
  end
end
