class Follower
  attr_reader :url, :name, :follower_id

  def initialize(data)
    @url = data[:html_url]
    @name = data[:login]
    @follower_id = data[:id]
  end
end
