# frozen_string_literal: true

RSpec.describe "Discover Theme - Anon", system: true do
  let!(:theme) { upload_theme }

  fab!(:tag)

  before do
    theme.update_setting(
      :homepage_filter,
      [{ tag: [tag.name], icon: "times", button_text: "news" }],
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
end
