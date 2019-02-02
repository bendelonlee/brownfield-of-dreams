require 'rails_helper'

describe 'as a user on the dashboard screen' do
  it 'can connect to Github' do
    stub_omniauth
    user = create(:user)
		allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)

    VCR.use_cassette("services/find_repositories") do
      VCR.use_cassette("services/find_followers") do
        VCR.use_cassette("services/find_followings") do
          visit '/dashboard'
        end
      end
    end

		expect(page).to have_link("Connect Your Github")

		click_on "Connect Your Github"
    save_and_open_page

		expect(page).to_not have_link("Connect Your Github")
  end

  def stub_omniauth
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:github] = nil
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      "uid" => "12345",
      "provider" => "github",
      "credentials" => {
        "token" => "12345"}})
  end
end
