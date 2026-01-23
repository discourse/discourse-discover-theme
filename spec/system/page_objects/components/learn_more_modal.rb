# frozen_string_literal: true

module PageObjects
  module Components
    class LearnMoreModal < PageObjects::Components::Base
      MODAL_SELECTOR = ".learn-more-modal"
      CLOSE_BUTTON_SELECTOR = "#{MODAL_SELECTOR} .modal-close"
      OPEN_BUTTON_SELECTOR = ".add-your-site button"

      def open
        find(OPEN_BUTTON_SELECTOR).click
        self
      end

      def close
        find(CLOSE_BUTTON_SELECTOR).click
        self
      end

      def visible?
        has_css?(MODAL_SELECTOR)
      end

      def has_modal?
        visible?
      end

      def has_no_modal?
        has_no_css?(MODAL_SELECTOR)
      end
    end
  end
end
