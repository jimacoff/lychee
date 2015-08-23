module ApplicationHelper
  def icon_tag(icon)
    content_tag('i', '', class: "fa fa-#{icon}")
  end
end
