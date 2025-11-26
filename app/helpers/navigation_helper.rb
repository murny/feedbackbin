# frozen_string_literal: true

module NavigationHelper
  def enabled_module_options(organization)
    options = []
    options << [ t("modules.posts"), "posts" ] if organization.posts_enabled?
    options << [ t("modules.roadmap"), "roadmap" ] if organization.roadmap_enabled?
    options << [ t("modules.changelog"), "changelog" ] if organization.changelog_enabled?
    options
  end

  def module_link_to(module_name, text, path, **options)
    return unless Current.organization.module_enabled?(module_name)
    link_to text, path, **options
  end

  def safe_module_path(module_name)
    if Current.organization.module_enabled?(module_name)
      case module_name.to_sym
      when :posts
        posts_path
      when :roadmap
        roadmap_path
      when :changelog
        changelogs_path
      end
    else
      root_path
    end
  end
end
