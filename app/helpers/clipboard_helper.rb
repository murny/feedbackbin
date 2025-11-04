# frozen_string_literal: true

module ClipboardHelper
  def button_to_copy_to_clipboard(url, title: "Copy to clipboard", success_title: "Copied!", &)
    tag.button class: "btn btn-sm btn-ghost", title: title, data: {
      controller: "copy-to-clipboard",
      action: "copy-to-clipboard#copy",
      copy_to_clipboard_success_class: "btn-sm-secondary",
      copy_to_clipboard_content_value: url,
      copy_to_clipboard_success_title_value: success_title,
      tooltip: title
    }, &
  end
end
