# frozen_string_literal: true

module PageObjects
  module Components
    class DiscoverNavigationList < PageObjects::Components::Base
      WRAPPER_SELECTOR = ".discover-navigation-list__filter-wrapper"

      def click_tag_filter(tag_name)
        find("button[data-tag-name='#{tag_name}']").click
        self
      end

      def click_all_filter
        all("#{WRAPPER_SELECTOR} button").first.click
        self
      end

      def has_tag_filter?(tag_name)
        has_css?("button[data-tag-name='#{tag_name}']")
      end

      def has_active_tag_filter?(tag_name)
        has_css?("button[data-tag-name='#{tag_name}'].--active")
      end
    end
  end
end
