module ApplicationHelper
  def responsive_image(image_instance, sizes, classes)
    default_image = image_instance.image.image_files.default_image
    options = { src: default_image.uri_path,
                srcset: image_instance.image.srcset_path,
                sizes: sizes, alt: image_instance.description,
                class: classes }
    content_tag(:img, nil, options)
  end
end
