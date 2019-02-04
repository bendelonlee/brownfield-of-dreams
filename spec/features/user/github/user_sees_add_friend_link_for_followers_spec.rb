require 'rails_helper'

describe "as a logged in user" do
  describe "on the dashboard" do
    it "shows add friend link next to followers who are in the database & not already friends" do
      current_user = create(:user, github_token: ENV["GITHUB_API_KEY"])
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)

      anton = create(:user, github_uid: 'cebarks')
      create(:user, github_uid: 'asmolentzov')

      Friendship.create(user_id: current_user.id, friend_id: anton.id)

      VCR.use_cassette("services/find_repositories") do
        VCR.use_cassette("services/find_followers") do
          VCR.use_cassette("services/find_followings") do
            visit '/dashboard'
          end
        end
      end

      expect(current_path).to eq('/dashboard')
      expect(page).to have_content("Followers:")

      within('#follower-cebarks') do
        expect(page).to have_link("cebarks")
        expect(page).to_not have_content("Add as Friend")
      end

      within('#following-asmolentzov') do
        expect(page).to have_link("asmolentzov")
        expect(page).to have_content("Add as Friend")
      end

      within('#following-mgoodhart5') do
        expect(page).to have_link("mgoodhart5")
        expect(page).to_not have_content("Add as Friend")
      end
    end

    it "can add follower or following as a friend" do
      current_user = create(:user, github_token: ENV["GITHUB_API_KEY"])
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(current_user)

      anton = create(:user, github_uid: 'cebarks')
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
      within('#follower-cebarks') do
        expect(page).to have_link("cebarks")
        expect(page).to have_content("Add as Friend")

        VCR.use_cassette("services/find_repositories") do
          VCR.use_cassette("services/find_followers") do
            VCR.use_cassette("services/find_followings") do
              click_on "Add as Friend"
            end
          end
        end
      end

      expect(current_user.friendships.last.friend_id).to eq(anton.id)
      expect(page).to have_content("Your friendship was added successfully!")
      expect(page).to_not have_content("ERROR: Your friendship was not saved!")

      within('#friend-cebarks') do
        expect(page).to have_link("cebarks")
        expect(page).to_not have_link("asmolentzov")
      end
    end
  end
end
