# frozen_string_literal: true

begin
  require 'coveralls'
  Coveralls.wear!
rescue LoadError
  warn 'coveralls not loaded'
end

require 'minitest/autorun'
require 'spidr'

require 'validate_website/core'

require File.expand_path('webmock_helper', __dir__)

TEST_DOMAIN = 'http://www.example.com/'
ENV['LC_ALL'] = 'C.UTF-8' if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
