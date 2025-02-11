# frozen_string_literal: true

module DocNavigationsHelper
  def header_with_anchor(header_tag: :h2, title:)
    id = title.parameterize
    header_class = "group"
    link_class = "hidden align-middle group-hover:inline-block p-1"
    icon_class = "text-gray-500 h-4 w-4"

    icon = inline_svg_tag(
      "icons/outline/link.svg",
      class: icon_class,
      aria: true,
      title: "Link",
      desc: "Link icon"
    )

    content_tag(header_tag, id: id, class: header_class) do
      tag.span(title) + link_to(icon, "##{id}", class: link_class)
    end
  end
end
