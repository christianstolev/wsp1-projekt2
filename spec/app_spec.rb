require_relative 'spec_helper'

RSpec.describe "Sinatra App", type: :feature do
  it "loads the homepage" do
    visit '/'
    expect(page).to have_content("Welcome") # Adjust based on your app
  end

  it "navigates to another page" do
    visit '/about'
    expect(page).to have_content("About Us") # Adjust based on your app
  end
end