require 'uri'
require 'net/http'
require 'open-uri'

class HackerNews

  VERSION = '0.1.0'

  # Returns the version string for the library.
  def self.version
    VERSION
  end

  BASE_URL = 'http://news.ycombinator.com'
  USER_URL = 'http://news.ycombinator.com/user?id=%s'
  
  # Creates a new HackerNews object.
  # Specify your username and password.
  def initialize(username, password)
    login_url = open(BASE_URL).read.match(/href="([^"]+)">login<\/a>/)[1]
    form_html = open(BASE_URL + login_url).read
    submit_url = URI.parse(BASE_URL)
    response = Net::HTTP.new(submit_url.host, submit_url.port).start do |http|
      req = Net::HTTP::Post.new('/y')
      req.set_form_data(
        'fnid' => form_html.match(/<input type=hidden name="fnid" value="([^"]+)"/)[1],
        'u'    => username,
        'p'    => password
      )
      http.request(req)
    end
    @cookie = response.header['set-cookie']
    @username = username
    @password = password
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
      url = URI.parse(USER_URL % username)
      response = Net::HTTP.start(url.host, url.port) do |http|
        header = {'Cookie' => @cookie}
        http.get(url.path + '?' + url.query, header)
      end
      response.body
    end
  end

end
