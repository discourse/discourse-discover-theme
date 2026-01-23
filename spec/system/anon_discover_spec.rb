# frozen_string_literal: true

require_relative "page_objects/pages/discover"
require_relative "page_objects/components/discover_navigation_list"
require_relative "page_objects/components/learn_more_modal"
require_relative "page_objects/components/discover_locale_switcher"

RSpec.describe "Discover Theme - Anon", system: true do
  let!(:theme) { upload_theme }

  fab!(:tag) { Fabricate(:tag, name: "news") }

  let(:discover_page) { PageObjects::Pages::Discover.new }
  let(:navigation_list) { PageObjects::Components::DiscoverNavigationList.new }
  let(:learn_more_modal) { PageObjects::Components::LearnMoreModal.new }
  let(:locale_switcher) { PageObjects::Components::DiscoverLocaleSwitcher.new }

  before do
    theme.update_setting(
      :homepage_filter,
      [{ tag: [tag.name], icon: "xmark", button_text: "news" }],
    )

    theme.save!
  end

  it "displays nav list based on setting" do
    discover_page.visit_home

    expect(navigation_list).to have_tag_filter(tag.name)
  end

  it "clicking nav item adds active class" do
    discover_page.visit_home

    navigation_list.click_tag_filter(tag.name)

    expect(navigation_list).to have_active_tag_filter(tag.name)
  end

  it "filtering to no results shows remove filter button, which removes input value" do
    discover_page.visit_home

    discover_page.fill_filter("squirrel!")

    sleep 5

    expect(discover_page).to have_clear_filter_button

    discover_page.click_clear_filter

    expect(discover_page.filter_input_value).to eq("")
  end

  it "redirects anonymous visitors back home" do
    visit("/c/1")

    expect(page).to have_current_path("/", ignore_query: true)
  end

  it "triggers FAQ modal on button click" do
    discover_page.visit_home

    learn_more_modal.open

    expect(learn_more_modal).to have_modal
  end

  it "?faq param triggers modal, closing modal removes param" do
    discover_page.visit_with_faq

    expect(learn_more_modal).to have_modal

    learn_more_modal.close

    expect(page).to have_current_path("/", ignore_query: true)
  end

  describe "URL query parameters" do
    it "?tag param activates the corresponding filter" do
      discover_page.visit_with_tag(tag.name)

      expect(navigation_list).to have_active_tag_filter(tag.name)
    end

    it "clicking a filter updates the URL with ?tag param" do
      discover_page.visit_home

      navigation_list.click_tag_filter(tag.name)

      expect(page).to have_current_path("/?tag=#{tag.name}")
    end

    it "clicking 'All' filter removes tag param from URL" do
      discover_page.visit_with_tag(tag.name)

      navigation_list.click_all_filter

      expect(page).to have_current_path("/")
    end

    it "?q param fills the search input and triggers search" do
      discover_page.visit_with_query("testing")

      expect(discover_page.filter_input_value).to eq("testing")
    end

    it "searching updates the URL with ?q param" do
      discover_page.visit_home

      discover_page.fill_filter("hello")

      sleep 1

      expect(page).to have_current_path("/?q=hello")
    end

    it "clearing search removes ?q param from URL" do
      discover_page.visit_with_query("xyznonexistent123")

      expect(discover_page).to have_clear_filter_button

      discover_page.click_clear_filter

      expect(page).to have_current_path("/")
    end

    context "with locale filter configured" do
      fab!(:locale_en_tag) { Fabricate(:tag, name: "locale-en") }
      fab!(:locale_fr_tag) { Fabricate(:tag, name: "locale-fr") }

      before do
        theme.update_setting(
          :locale_filter,
          [
            { tag: [locale_en_tag.name], text: "English" },
            { tag: [locale_fr_tag.name], text: "French" },
          ],
        )

        theme.save!
      end

      it "?locale param sets the locale filter" do
        discover_page.visit_with_locale("fr")

        expect(locale_switcher).to have_selected_locale("locale-fr")
      end

      it "changing locale updates the URL with ?locale param" do
        discover_page.visit_home

        locale_switcher.select_locale("locale-fr")

        expect(page).to have_current_path("/?locale=fr")
      end
    end
  end
end
