require 'spec_helper'

describe GoogleAnalyticsMailer do

  it "ActionMailer::Base should extend GoogleAnalyticsMailer" do
    (class << ActionMailer::Base; self end).included_modules.should include(GoogleAnalyticsMailer)
  end

  describe ".google_analytics_mailer" do

    class TestMailer1 < ActionMailer::Base
    end

    it "should assign given parameters to a class variable" do
      params = {utm_source: 'newsletter', utm_medium: 'email'}
      TestMailer1.google_analytics_mailer(params)
      TestMailer1.google_analytics_class_params.should == params
    end

  end

  class UserMailer < ActionMailer::Base
    default :from => 'no-reply@example.com'

    # declare url parameters for this mailer
    google_analytics_mailer utm_source: 'newsletter', utm_medium: 'email' # etc

    # simulate url helper
    helper do
      def newsletter_url params = {}
        'http://www.example.com/newsletter'.tap do |u|
          u << "?#{params.to_param}" if params.any?
        end.html_safe
      end
    end

    # Links in this email will have all links with GA params automatically inserted
    def welcome
      mail(to: 'user@example.com')
    end

    def welcome2
      google_analytics_params(utm_source: 'second_newsletter', utm_term: 'welcome2')
      mail(to: 'user@example.com')
    end

    def welcome3
      mail(to: 'user@example.com')
    end

  end

  describe UserMailer do

    # see view in spec/support/views/user_mailer/welcome.html.erb
    describe "#welcome" do

      subject { UserMailer.welcome }

      it "should have analytics link with params taken from class definition" do
        subject.should have_body_text 'http://www.example.com/newsletter?utm_medium=email&utm_source=newsletter'
      end

      it "should have analytics link with overridden params" do
        subject.should have_body_text 'http://www.example.com/newsletter?utm_medium=email&utm_source=my_newsletter'
      end

    end

    # see view in spec/support/views/user_mailer/welcome2.html.erb
    describe "#welcome2" do

      subject { UserMailer.welcome2 }

      it "should have analytics link with params taken from instance" do
        subject.should have_body_text 'http://www.example.com/newsletter?utm_medium=email&utm_source=second_newsletter&utm_term=welcome2'
      end

      it "should have analytics link with overridden params" do
        subject.should have_body_text 'http://www.example.com/newsletter?utm_medium=email&utm_source=my_newsletter&utm_term=welcome2'
      end

    end

    # see view in spec/support/views/user_mailer/welcome3.html.erb
    describe "#welcome3" do

      subject { UserMailer.welcome3 }

      it "should have analytics link with params taken from view" do
        subject.should have_body_text 'http://www.example.com/newsletter?utm_medium=email&utm_source=newsletter&utm_term=footer'
      end

    end

  end

end
