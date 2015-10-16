module Publishing
  module Images
    def image_instance(json, ii)
      json.call(ii, :id, :name, :description, :order)
      optional_fields(json, ii, [:metadata, :metadata_fields, :tags])
      json.image do
        image(json, ii.image)
      end
    end

    def image(json, img)
      json.call(img, :id, :internal_name, :extension)
      image_paths(json, img)
      optional_fields(json, img, [:metadata, :metadata_fields, :tags])
      json.default do
        image_file(json, img.image_files.default_image)
      end
      json.original do
        image_file(json, img.image_files.original_image)
      end
      image_srcset(json, img)
    end

    def image_paths(json, img)
      json.paths do
        json.default img.default_path
        json.srcset img.srcset_path
      end
    end

    def image_srcset(json, img)
      json.srcset do
        json.array! img.image_files.srcset do |image_file|
          image_file(json, image_file, srcset_path: true)
        end
      end
    end

    def image_file(json, image_file, srcset_path: false)
      json.call(image_file, :id, :filename, :width, :height, :uri_path)
      json.srcset_path image_file.srcset_path if srcset_path
      json.x_dimension image_file.x_dimension if image_file.x_dimension
      optional_fields(json, image_file, [:metadata])
    end
  end
end
