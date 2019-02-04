class Following
  attr_reader :url, :name, :following_id

  def initialize(data)
    @url = data[:html_url]
    @name = data[:login]
    @following_id = data[:id]
  end
end
