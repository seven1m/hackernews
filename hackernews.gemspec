require File.dirname(__FILE__) + '/lib/hackernews'

Gem::Specification.new do |s|
  s.name         = "hackernews"
  s.version      = HackerNews::VERSION
  s.author       = "Tim Morgan"
  s.email        = "tim@timmorgan.org"
  s.homepage     = "http://rdoc.info/projects/seven1m/hackernews"
  s.summary      = "Ruby gem to login and interact with the Hacker News website."
  s.require_path = "lib"
  s.has_rdoc     = true
  s.files        = %w(
    README.rdoc
    lib/hackernews.rb
    test/hackernews_test.rb
  )
end
