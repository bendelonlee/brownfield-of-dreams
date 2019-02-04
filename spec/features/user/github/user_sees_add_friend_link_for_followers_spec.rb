require 'rails_helper'

describe "as a logged in user" do
  describe "on the dashboard" do
    it "shows add friend link next to followers who are in your database with a github token" do
      current_user = create(:user, github_token: ENV["GITHUB_API_KEY"])
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)

      create(:user, github_uid: 'cebarks')
      create(:user, github_uid: 'nicovigil1')
      create(:user, github_uid: 'asmolentzov')

      VCR.use_cassette("services/find_repositories") do
        VCR.use_cassette("services/find_followers") do
          VCR.use_cassette("services/find_followings") do
            visit '/dashboard'
          end
        end
      end

      expect(current_path).to eq('/dashboard')
      expect(page).to have_content("Followers:")
      save_and_open_page
      within('#follower-cebarks') do
        expect(page).to have_link("cebarks")
        expect(page).to have_content("Add as Friend")
      end
      within('#following-asmolentzov') do
        expect(page).to have_link("asmolentzov")
        expect(page).to have_content("Add as Friend")
      end
      within('#follower-nicovigil1') do
        expect(page).to have_link("nicovigil1")
        expect(page).to_not have_content("Add as Friend")
      end
      within('#following-mgoodhart5') do
        expect(page).to have_link("mgoodhart5")
        expect(page).to_not have_content("Add as Friend")
      end
    end
  end
end
