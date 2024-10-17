# frozen_string_literal: true

RSpec.describe "Discover Theme - Admin", system: true do
  let!(:theme) { upload_theme }

  fab!(:admin)

  before { sign_in(admin) }

  it "does not redirect admins back home" do
    visit("/c/1")

    expect(page).to have_current_path("/c/uncategorized/1", ignore_query: true)
  end
end
