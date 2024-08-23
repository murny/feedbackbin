# frozen_string_literal: true

module ActiveLinksHelper
  def active_link_to(name = nil, options = {}, html_options = {}, &block)
    if block
      html_options = options
      options = name
      name = block
    end

    url = url_for(options)
    active = active_link?(url, html_options.delete(:starts_with))

    # Append the active or inactive class options depending on the active state
    html_options[:class] = Array.wrap(html_options[:class])
    active_class = html_options.delete(:active_class) || "active"
    inactive_class = html_options.delete(:inactive_class) || ""
    classes = active ? active_class : inactive_class
    html_options[:class] << classes unless classes.empty?
    html_options.except!(:class) if html_options[:class].empty?

    if block
      link_to(url, html_options, &block)
    else
      link_to(name, url, html_options)
    end
  end

  private

  # Figure out if we are "active" based on current request path and starts_with option
  def active_link?(url, starts_with)
    paths = Array.wrap(starts_with)
    if paths.present?
      paths.any? { |path| request.path.start_with?(path) }
    else
      request.path == url
    end
  end
end
