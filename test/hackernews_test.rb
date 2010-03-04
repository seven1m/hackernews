require 'test/unit'
require File.dirname(__FILE__) + '/../lib/hackernews.rb'

class HackerNewsTest < Test::Unit::TestCase

  def setup
    unless ENV['HN_USERNAME'] and ENV['HN_PASSWORD']
      puts 'Must set HN_USERNAME and HN_PASSWORD env variables before running.'
      exit(1)
    end
    @hn = HackerNews.new
  end
  
  def login
    @hn.login(ENV['HN_USERNAME'], ENV['HN_PASSWORD'])
  end

  def test_session_cookie
    login
    assert @hn.instance_eval('@cookie') =~ /user=[a-z0-9]+;/i
  end
  
  def test_login_failure
    assert_raise HackerNews::LoginError do
      @hn.login('foobar00000', 'baz')
    end
  end
  
  def test_karma
    assert @hn.karma('pg').to_i > 59000
    login
    assert @hn.karma.to_s != ''
  end
  
  def test_average_karma
    assert_raise HackerNews::LoginError do
      @hn.average_karma
    end
    login
    assert @hn.average_karma.to_s != ''
  end

end
