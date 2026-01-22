# frozen_string_literal: true

RSpec.describe "Discover Theme - Anon", system: true do
  let!(:theme) { upload_theme }

  fab!(:tag) { Fabricate(:tag, name: "news") }

  before do
    theme.update_setting(
      :homepage_filter,
      [{ tag: [tag.name], icon: "xmark", button_text: "news" }],
    )

    theme.save!
  end

  it "displays nav list based on setting" do
    visit("/")

    expect(page).to have_css("button[data-tag-name='#{tag.name}']")
  end

  it "clicking nav item adds active class" do
    visit("/")

    find("button[data-tag-name='#{tag.name}']").click

    expect(page).to have_css("button[data-tag-name='#{tag.name}'].--active")
  end

  it "filtering to no results shows remove filter button, which removes input value" do
    visit("/")

    fill_in "filter", with: "squirrel!"

    sleep 5

    expect(page).to have_css(".no-results .--link-button")

    find(".no-results .--link-button").click

    expect(find("#filter").value).to eq("")
  end

  it "redirects anonymous visitors back home" do
    visit("/c/1")

    expect(page).to have_current_path("/", ignore_query: true)
  end

  it "triggers FAQ modal on button click" do
    visit("/")

    find(".add-your-site button").click

    expect(page).to have_css(".learn-more-modal")
  end

  it "?faq param triggers modal, closing modal removes param" do
    visit("/?faq")

    expect(page).to have_css(".learn-more-modal")

    find(".learn-more-modal .modal-close").click

    expect(page).to have_current_path("/", ignore_query: true)
  end

  describe "URL query parameters" do
    it "?tag param activates the corresponding filter" do
      visit("/?tag=#{tag.name}")

      expect(page).to have_css("button[data-tag-name='#{tag.name}'].--active")
    end

    it "clicking a filter updates the URL with ?tag param" do
      visit("/")

      find("button[data-tag-name='#{tag.name}']").click

      expect(page).to have_current_path("/?tag=#{tag.name}")
    end

    it "clicking 'All' filter removes tag param from URL" do
      visit("/?tag=#{tag.name}")

      all(".discover-navigation-list__filter-wrapper button").first.click

      expect(page).to have_current_path("/")
    end

    it "?q param fills the search input and triggers search" do
      visit("/?q=testing")

      expect(find("#filter").value).to eq("testing")
    end

    it "searching updates the URL with ?q param" do
      visit("/")

      fill_in "filter", with: "hello"

      sleep 1

      expect(page).to have_current_path("/?q=hello")
    end

    it "clearing search removes ?q param from URL" do
      visit("/?q=xyznonexistent123")

      expect(page).to have_css(".no-results .--link-button")

      find(".no-results .--link-button").click

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
        visit("/?locale=fr")

        expect(page).to have_css(".locale-switcher .select-kit-header[data-value='locale-fr']")
      end

      it "changing locale updates the URL with ?locale param" do
        visit("/")

        find(".locale-switcher").click
        find(".select-kit-row[data-value='locale-fr']").click

        expect(page).to have_current_path("/?locale=fr")
      end
    end
  end
end
