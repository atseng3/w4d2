class User < ActiveRecord::Base
  attr_accessible :twitter_user_id, :screen_name

  validates :twitter_user_id, presence: true, uniqueness: true
  validates :screen_name, presence: true, uniqueness: true

  has_many :statuses,
           :primary_key => :twitter_user_id,
           :foreign_key => :twitter_user_id,
           :class_name => "Status"

  has_many :inbound_follows,
           :primary_key => :twitter_user_id,
           :foreign_key => :twitter_followee_id,
           :class_name => 'Follow'

  has_many :outbound_follows,
           :primary_key => :twitter_user_id,
           :foreign_key => :twitter_follower_id,
           :class_name => 'Follow'

  has_many :followed_users, :through => :outbound_follows, :source => :followee

  has_many :followers, :through => :inbound_follows, :source => :follower

  def self.fetch_by_id(twitter_user_ids)
    users_found = []
    twitter_user_ids_dup = twitter_user_ids.dup
    twitter_user_ids.each do |user_id|
      unless User.find_by_id(user_id).nil?
        users_found << User.find_by_id(user_id)
        twitter_user_ids_dup.delete(user_id)
      end
    end
    p twitter_user_ids_dup.join(",")
    request_urls = Addressable::URI.new(:scheme => 'https',
                                        :host => "api.twitter.com",
                                        :path => "1.1/users/lookup.json",
                                        :query_values => {
                                        :user_id => "#{twitter_user_ids_dup.join(",")}"}
                                        ).to_s

    User.parse_twitter_params(TwitterSession.get(request_urls).body)
    return nil
  end


  def self.fetch_by_screen_name(screen_name)
    unless User.find_by_screen_name(screen_name).nil?
      return User.find_by_screen_name(screen_name)
    else
      request_url = Addressable::URI.new( :scheme => "https",
                                          :host => "api.twitter.com",
                                          :path => "1.1/users/show.json",
                                          :query_values => {
                                          :screen_name => "#{screen_name}"}
                                         ).to_s

      User.parse_twitter_params(TwitterSession.get(request_url).body)
    end
  end

  def self.parse_twitter_params(params)
    user_params = JSON.parse(params)
    unless user_params.is_a?(Array)
      User.create!({ twitter_user_id: user_params["id"],
                     screen_name: user_params["screen_name"]})
    else
      user_params.each do |user_param|
        User.create!({ twitter_user_id: user_params["id"],
                       screen_name: user_params["screen_name"]})
      end
    end
  end
end
