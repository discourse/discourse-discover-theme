# frozen_string_literal: true

module PageObjects
  module Components
    class DiscoverLocaleSwitcher < PageObjects::Components::Base
      SWITCHER_SELECTOR = ".locale-switcher"

      def select_locale(locale_value)
        find(SWITCHER_SELECTOR).click
        find(".select-kit-row[data-value='#{locale_value}']").click
        self
      end

      def has_selected_locale?(locale_value)
        has_css?("#{SWITCHER_SELECTOR} .select-kit-header[data-value='#{locale_value}']")
      end
    end
  end
end
