# encoding: UTF-8
require File.expand_path('../spec_helper', __FILE__)

describe ValidateWebsite::Core do
  before do
    WebMock.reset!
    stub_request(:get, ValidateWebsite::Core::PING_URL).to_return(status: 200)
    stub_request(:get, /#{SPEC_DOMAIN}/).to_return(status: 200)
    @validate_website = ValidateWebsite::Core.new(color: false)
  end

  describe 'invalid options' do
    it 'raise ArgumentError on wrong validation_type' do
      proc {
        ValidateWebsite::Core.new({ color: false }, :fail)
      }.must_raise ArgumentError
    end
  end

  describe 'options' do
    it 'can change user-agent' do
      ua = %{Linux / Firefox 29: Mozilla/5.0 (X11; Linux x86_64; rv:29.0) \
      Gecko/20100101 Firefox/29.0}
      v = ValidateWebsite::Core.new({ site: SPEC_DOMAIN, user_agent: ua },
                                    :crawl)
      v.crawl
      v.crawler.user_agent.must_equal ua
    end
  end

  describe('cookies') do
    it 'can set cookies' do
      cookies = 'tz=Europe%2FBerlin; guid=ZcpBshbtStgl9VjwTofq'
      v = ValidateWebsite::Core.new({ site: SPEC_DOMAIN, cookies: cookies },
                                    :crawl)
      v.crawl
      v.crawler.cookies.cookies_for_host(v.host).must_equal v.default_cookies
    end
  end

  describe('html') do
    it "extract url" do
      name = 'xhtml1-strict'
      file = File.join('spec', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: open(file).read,
                          content_type: 'text/html')
      @validate_website.site = page.url
      @validate_website.crawl
      @validate_website.crawler.history.size.must_equal 5
    end

    it 'extract link' do
      name = 'html4-strict'
      file = File.join('spec', 'data', "#{name}.html")
      page = FakePage.new(name,
                          body: open(file).read,
                          content_type: 'text/html')
      @validate_website.site = page.url
      @validate_website.crawl
      @validate_website.crawler.history.size.must_equal 98
    end
  end

  describe('css') do
    it "crawl css and extract url" do
      page = FakePage.new('test.css',
                          body: '.t {background-image: url(pouet);}
                                 .t {background-image: url(/image/pouet.png)}
                                 .t {background-image: url(/image/pouet_42.png)}
                                 .t {background-image: url(/image/pouet)}',
                          content_type: 'text/css')
      @validate_website.site = page.url
      @validate_website.crawl
      @validate_website.crawler.history.size.must_equal 5
    end

    it "should extract url with single quote" do
      page = FakePage.new('test.css',
                          body: ".test {background-image: url('pouet');}",
                          content_type: 'text/css')
      @validate_website.site = page.url
      @validate_website.crawl
      @validate_website.crawler.history.size.must_equal 2
    end

    it "should extract url with double quote" do
      page = FakePage.new('test.css',
                          body: ".test {background-image: url(\"pouet\");}",
                          content_type: 'text/css')
      @validate_website.site = page.url
      @validate_website.crawl
      @validate_website.crawler.history.size.must_equal 2
    end
  end

  describe('static') do
    it 'no space in directory name' do
      pattern = File.join(File.dirname(__FILE__), 'example/**/*.html')
      @validate_website.crawl_static(pattern: pattern,
                                     site: 'http://dev.af83.com/',
                                     markup: false,
                                     not_found: false)
      @validate_website.not_founds_count.must_equal 0
    end

    it 'not found' do
      pattern = File.join(File.dirname(__FILE__), '**/*.html')
      Dir.chdir('spec/data') do
        @validate_website.crawl_static(pattern: pattern,
                                       site: 'https://linuxfr.org/',
                                       markup: false,
                                       not_found: true)
        @validate_website.not_founds_count.must_equal 464
      end
    end
  end
end
