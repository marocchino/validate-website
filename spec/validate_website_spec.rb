require File.dirname(__FILE__) + '/spec_helper'

describe ValidateWebsite do

  before(:each) do
    FakeWeb.clean_registry
  end

  context('html') do
    it "should extract url" do
      name = 'xhtml1-strict'
      file = File.join('spec', 'data', "#{name}.html")
      page = FakePage.new(name,
                          :body => open(file).read,
                          :content_type => 'text/html')
      validate_website = ValidateWebsite.new
      validate_website.crawl(page.url)
      validate_website.anemone.should have(3).pages
    end
  end

  context('css') do
    it "should crawl css and extract url" do
      page = FakePage.new('test.css',
                          :body => ".test {background-image: url(pouet);}
                                    .tests {background-image: url(/image/pouet.png)}
                                    .tests {background-image: url(/image/pouet_42.png)}
                                    .tests {background-image: url(/image/pouet)}",
                          :content_type => 'text/css')
      validate_website = ValidateWebsite.new
      validate_website.crawl(page.url)
      validate_website.anemone.should have(5).pages
    end

    it "should extract url with single quote" do
      page = FakePage.new('test.css',
                            :body => ".test {background-image: url('pouet');}",
                            :content_type => 'text/css')
      validate_website = ValidateWebsite.new
      validate_website.crawl(page.url)
      validate_website.anemone.should have(2).pages
    end

    it "should extract url with double quote" do
      page = FakePage.new('test.css',
                          :body => ".test {background-image: url(\"pouet\");}",
                          :content_type => 'text/css')
      validate_website = ValidateWebsite.new
      validate_website.crawl(page.url)
      validate_website.anemone.should have(2).pages
    end
  end
end