# frozen_string_literal: true

RSpec.describe "Core features", type: :system do
  fab!(:active_user) { Fabricate(:active_user, password: "secure_password") }
  fab!(:topics) { Fabricate.times(3, :topic_with_op, category:) }
  fab!(:category) { Fabricate(:category, name: "General") }

  before { upload_theme_or_component }

  describe "User profile" do
    fab!(:user)

    before { UserStat.update_all(post_count: 1) }

    context "with a logged in user" do
      before { sign_in(active_user) }

      it "displays a user’s profile" do
        visit("/u/#{user.username}/summary")
        expect(page).to have_content(user.name)
        expect(page).to have_content("Message")
      end

      it "displays the user’s own profile" do
        visit("/u/#{active_user.username}/summary")
        expect(page).to have_content(active_user.name)
        expect(page).to have_content("Preferences")
      end
    end
  end

  describe "Search" do
    let(:search_page) { PageObjects::Pages::Search.new }

    before do
      SearchIndexer.enable
      topics.each { SearchIndexer.index(_1, force: true) }
      Fabricate(:theme_site_setting_with_service, name: "enable_welcome_banner", value: false)
    end

    after { SearchIndexer.disable }

    context "with a logged in user" do
      before { sign_in(active_user) }

      it "searches using the full page search" do
        visit("/search")

        search_page.type_in_search(topics.first.title)
        search_page.click_search_button

        expect(search_page).to have_search_result
      end
    end
  end
end
