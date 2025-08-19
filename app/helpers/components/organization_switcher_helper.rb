# frozen_string_literal: true

module Components
  module OrganizationSwitcherHelper
    # Creates an organization switcher dropdown component
    #
    # @param classes [String] Additional CSS classes to apply to the component
    # @param current_organization [Organization] The currently selected organization
    # @param organizations [ActiveRecord::Relation] Collection of organizations user can switch between
    # @return [ActiveSupport::SafeBuffer] The rendered organization switcher component
    def render_organization_switcher(classes: "", current_organization: Current.organization, organizations: Current.organizations)
      render "components/organization_switcher/organization_switcher",
             current_organization: current_organization,
             organizations: organizations,
             classes: classes
    end
  end
end
