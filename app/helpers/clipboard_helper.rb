# frozen_string_literal: true

module ClipboardHelper
  def button_to_copy_to_clipboard(url, title: "Copy to clipboard", success_title: "Copied!", &block)
    render Ui::ButtonComponent.new(variant: :outline, size: :icon, title: title, data: {
      controller: "copy-to-clipboard",
      action: "copy-to-clipboard#copy",
      copy_to_clipboard_success_class: "border-primary text-primary",
      copy_to_clipboard_content_value: url,
      copy_to_clipboard_success_title_value: success_title,
      tooltip: title
    }), &block
  end
end
