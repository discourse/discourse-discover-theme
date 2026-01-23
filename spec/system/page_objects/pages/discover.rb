# frozen_string_literal: true

module PageObjects
  module Pages
    class Discover < PageObjects::Pages::Base
      FILTER_INPUT_SELECTOR = "#filter"
      CLEAR_FILTER_BUTTON_SELECTOR = ".no-results .--link-button"

      def visit_home
        visit("/")
        self
      end

      def visit_with_tag(tag_name)
        visit("/?tag=#{tag_name}")
        self
      end

      def visit_with_query(query)
        visit("/?q=#{query}")
        self
      end

      def visit_with_locale(locale)
        visit("/?locale=#{locale}")
        self
      end

      def visit_with_faq
        visit("/?faq")
        self
      end

      def fill_filter(value)
        fill_in "filter", with: value
        self
      end

      def filter_input_value
        find(FILTER_INPUT_SELECTOR).value
      end

      def click_clear_filter
        find(CLEAR_FILTER_BUTTON_SELECTOR).click
        self
      end

      def has_clear_filter_button?
        has_css?(CLEAR_FILTER_BUTTON_SELECTOR)
      end
    end
  end
end
