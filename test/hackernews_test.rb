require 'test/unit'
require File.dirname(__FILE__) + '/../lib/hackernews.rb'

class HackerNewsTest < Test::Unit::TestCase

  def setup
    if ENV['HN_USERNAME'] and ENV['HN_PASSWORD']
      @hn = HackerNews.new(ENV['HN_USERNAME'], ENV['HN_PASSWORD'])
    else
      puts 'Must set HN_USERNAME and HN_PASSWORD env variables before running.'
      exit(1)
    end
  end

  def test_session_cookie
    assert @hn.instance_eval('@cookie') =~ /user=[a-z0-9]+;/i
  end
  
  def test_login_failure
    assert_raise HackerNews::LoginError do
      HackerNews.new('foobar00000', 'baz')
    end
  end
  
  def test_karma
    assert @hn.karma.to_s != ''
    assert @hn.karma('pg').to_i > 59000
  end
  
  def test_average_karma
    assert @hn.average_karma.to_s != ''
  end

end
