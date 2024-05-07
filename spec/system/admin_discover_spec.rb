# frozen_string_literal: true

RSpec.describe "Discover Theme - Admin", system: true do
  let!(:theme) do 
    upload_theme
  end

  fab!(:admin) { Fabricate(:admin) }
  
  before do
    sign_in(admin)
  end

  it "does not redirect admins back home" do
    visit("/c/1")

    expect(page.current_path).to eq("/c/uncategorized/1")
  end
end
