require 'uri'
require 'net/http'
require 'open-uri'

class HackerNews

  VERSION = '0.2.0'

  # Returns the version string for the library.
  def self.version
    VERSION
  end

  BASE_URL           = "http://news.ycombinator.com"
  ITEM_URL           = "#{BASE_URL}/item?id=%s"
  USER_URL           = "#{BASE_URL}/user?id=%s"
  LOGIN_SUBMIT_URL   = "#{BASE_URL}/y"
  COMMENT_SUBMIT_URL = "#{BASE_URL}/r"
  
  class LoginError < RuntimeError; end
  
  # Creates a new HackerNews object.
  # Specify your username and password.
  def initialize(username = nil, password = nil)
    unless username.nil?
      login_url = get(BASE_URL).match(/href="([^"]+)">login<\/a>/)[1]
      form_html = get(BASE_URL + login_url)
      fnid = form_html.match(/<input type=hidden name="fnid" value="([^"]+)"/)[1]
      response = post(LOGIN_SUBMIT_URL, 'fnid' => fnid, 'u' => username, 'p' => password)
      @username = username
      @password = password
      unless @cookie = response.header['set-cookie']
        raise LoginError, "Login credentials did not work."
      end
    end
  end
  
  # Retrieves the karma for the logged in user, or for the specified username (if given).
  def karma(username=nil)
    user_page(username).match(/<td valign=top>karma\:<\/td><td>(\d+)<\/td>/)[1]
  end
  
  # Retrieves the average karma per post for the logged in user.
  def average_karma
    user_page.match(/<td valign=top>avg:<\/td><td>([\d\.]+)<\/td>/)[1]
  end
  
  # Retrieves the user page html for the specified username (or the current logged in user if none is specified).
  def user_page(username=nil)
    username ||= @username
    @user_pages ||= {}
    @user_pages[username] ||= begin
      get(USER_URL % username)
    end
  end
  
  # Up-vote a post or a comment by passing in the id number.
  def vote(id)
    require_login!
    url = get(ITEM_URL % id).match(/<a id=up_\d+ onclick="return vote\(this\)" href="(vote\?[^"]+)">/)[1]
    get(BASE_URL + '/' + url)
  end
  
  # Post a comment on a posted item or on another comment.
  def comment(id, text)
    require_login!
    fnid = get(ITEM_URL % id).match(/<input type=hidden name="fnid" value="([^"]+)"/)[1]
    post(COMMENT_SUBMIT_URL, 'fnid' => fnid, 'text' => text)
  end
  
  private
  
    def url_path_and_query(url)
      if url.path and url.query
        "#{url.path}?#{url.query}"
      elsif url.path.to_s.any?
        url.path
      else
        '/'
      end
    end
  
    def get(url)
      url = URI.parse(url)
      response = Net::HTTP.start(url.host, url.port) do |http|
        http.get(url_path_and_query(url), build_header)
      end
      response.body
    end
    
    def post(url, data)
      url = URI.parse(url)
      Net::HTTP.new(url.host, url.port).start do |http|
        req = Net::HTTP::Post.new(url.path, build_header)
        req.set_form_data(data)
        http.request(req)
      end
    end
    
    def build_header
      @cookie && {'Cookie' => @cookie}
    end
    
    def require_login!
      raise(LoginError, "Login credentials did not work.") unless @cookie
    end

end
