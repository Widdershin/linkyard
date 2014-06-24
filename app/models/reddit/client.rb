class Reddit::Client 
  def initialize(token, refresh_token)
    @connection = Connection.new(token, refresh_token)
  end

  def add_token_update_listener(&block)
    @connection.add_token_update_listener(&block)
  end

  def submit(url, title, subreddit, save: false, resubmit: false, send_replies: false)
    parameters = { 
      :api_type => "json",
      :extension => "json",
      :kind => "link",
      :sr => subreddit,
      :url => url,
      :title => title,
      :save => save,
      :resubmit => resubmit,
      :send_replies => send_replies
    }
    
    response(@connection.post("submit", parameters), [Submission])
  end

  def needs_captcha?
    @connection.get("needs_captcha.json") == 'true'
  end

  def vote(id, direction)
    response(@connection.post("vote", {:id => id, :dir => direction }), [Empty])
  end

  def me
    response(@connection.get("v1/me"), [Identity])
  end
  
  def info(url, subreddit)
    response(@connection.get("info.json", { :url => url }, "r/#{subreddit}/"), [Listing])
  end

  private
  def response(data, available_responses)
    Reddit::Response.new_from(data, available_responses)
  end
end
