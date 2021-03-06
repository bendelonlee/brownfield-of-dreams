require 'rails_helper'

describe UserDashboardFacade do
  it "it exists" do
    user = double
    allow(user).to receive(:github_token) {"klsfj"}
    facade = UserDashboardFacade.new(user)

    expect(facade).to be_a(UserDashboardFacade)
  end

  describe 'instance methods' do
    it '.repos' do
      VCR.use_cassette("services/find_repositories") do
        key = ENV["GITHUB_API_KEY"]
        user = create(:user, github_token: key)
        user_facade = UserDashboardFacade.new(user)
        repos = user_facade.repos

        expect(repos.count).to eq(5)
        expect(repos.first).to be_a(Repository)
      end
    end
    it '.followers' do
      VCR.use_cassette("services/find_followers") do
        key = ENV["GITHUB_API_KEY"]
        user = create(:user, github_token: key)
        user_facade = UserDashboardFacade.new(user)
        followers = user_facade.followers

        expect(followers.first).to be_a(Follower)
      end
    end
    it '.followings' do
      VCR.use_cassette("services/find_followings") do
        key = ENV["GITHUB_API_KEY"]
        user = create(:user, github_token: key)
        user_facade = UserDashboardFacade.new(user)
        followings = user_facade.followings

        expect(followings.first).to be_a(Following)
      end
    end
    it '#my_bookmarked_tutorials' do
      user = create(:user)
      tutorial_1 = create(:tutorial)
      tutorial_2 = create(:tutorial)
      video_1 = create(:video, tutorial: tutorial_1)
      video_2 = create(:video)
      user_video = create(:user_video, user: user, video: video_1)

      user_facade = UserDashboardFacade.new(user)

      expect(user_facade.my_bookmarked_tutorials).to eq([tutorial_1])
    end
    describe '#has_github?' do
      scenario 'when true' do
        user_1 = double("user with github")
        allow(user_1).to receive(:github_token) { "sdf34895f" }
        facade = UserDashboardFacade.new(user_1)
        expect(facade.has_github?).to eq(true)
      end
      scenario 'when false' do
        user_1 = spy("user without github")
        allow(user_1).to receive(:github_token) { nil }
        facade = UserDashboardFacade.new(user_1)
        expect(facade.has_github?).to eq(false)
        expect(user_1).to have_received(:github_token).twice
      end
    end
    it '.updated_friends' do
      user_1 = spy("user with non-updated friends")
      user_1_updated = spy("user with updated friends")
      allow(user_1).to receive(:reload) { user_1_updated }
      allow(user_1_updated).to receive(:friends) { "an updated list of friends" }

      facade = UserDashboardFacade.new(user_1)
      expect(facade.updated_friends).to eq("an updated list of friends")
      expect(user_1).to have_received(:reload)
      expect(user_1_updated).to have_received(:friends)
    end
    it 'friends_with?' do
      user_1, user_2, user_3 = create_list(:user, 3)
      user_1.friends << user_2

      facade = UserDashboardFacade.new(user_1)

      expect(facade.friends_with?(user_2)).to eq(true)
      expect(facade.friends_with?(user_3)).to eq(false)
    end
  end
end
