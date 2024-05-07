# frozen_string_literal: true

RSpec.describe "Discover Theme - Anon", system: true do
  let!(:theme) do 
    upload_theme
  end

  fab!(:tag)

  before do
    theme.update_setting(
      :homepage_filter,
      [
        {
          tag: [tag.name],
          icon: "times",
          button_text: "news",
        },
     
      ],
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

    expect(page.current_path).to eq("/")
  end
end
