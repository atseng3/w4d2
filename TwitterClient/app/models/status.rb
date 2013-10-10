class Status < ActiveRecord::Base
  attr_accessible :twitter_status_id, :body, :twitter_user_id
  validates :twitter_status_id, presence: true
  validates :twitter_user_id, presence: true

  belongs_to :user,
              primary_key: :twitter_user_id,
              foreign_key: :twitter_user_id,
              class_name: "User"

  def self.parse_twitter_params(params)
    user_params = JSON.parse(params)
    user_params.each do |tweet|
      unless Status.find_by_twitter_status_id(tweet["id"])
        Status.create!({ twitter_status_id: tweet["id"],
                         twitter_user_id: tweet["user"]["id"],
                         body: tweet["text"]})
      end
    end
    return nil
  end

  def self.fetch_statuses_for_user(user)
    request_url = Addressable::URI.new(
                                         :scheme => "https",
                                         :host => "api.twitter.com",
                                         :path => "1.1/statuses/user_timeline.json",
                                         :query_values => { :id => "#{user.twitter_user_id}"}
                                      ).to_s
    request_url
    Status.parse_twitter_params(TwitterSession.get(request_url).body)
  end
end
