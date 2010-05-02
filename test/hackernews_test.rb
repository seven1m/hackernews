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

  # This test is likely to break as often as pg changes the layout.
  # It's a good layout so hopefully it will not break frequently.
  # It will also break if jacquesm decides to delete his witty comment.
  def test_parse_story_comments
    parsed_comments = @hn.parse_story_comments(1220079)
    chasingsparks= parsed_comments.find{|c| c[:user_id] == 'chasingsparks'}
    assert_not_nil(chasingsparks)
    
    parsed_comments = @hn.parse_story_comments(1)
    jacquesm = parsed_comments.find{|c| c[:user_id] == 'jacquesm'}
    puts jacquesm.inspect
    assert_not_nil(jacquesm)
    assert_match(/longest span between article and comment/, jacquesm[:text])
  end

end
