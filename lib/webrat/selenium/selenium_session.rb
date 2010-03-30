require "webrat/core/save_and_open_page"

require "webrat/selenium/selenium_rc_server"
require "webrat/selenium/application_server_factory"
require "webrat/selenium/application_servers/base"
require "webrat/selenium/elements"

require "selenium"

module Webrat
  class TimeoutError < WebratError
  end

  class SeleniumResponse
    attr_reader :body
    attr_reader :session

    def initialize(session, body)
      @session = session
      @body = body
    end

    def selenium
      session.selenium
    end

    def is_text_present(text_finder)
      puts text_finder
      body.include? text_finder
    end
  end

  class SeleniumSession
    include Webrat::SaveAndOpenPage
    include Webrat::Selenium::SilenceStream
    extend Forwardable

    def_delegators :current_scope, :click_link_within, :clicks_link_within
    def_delegators :current_scope, :click_link,         :clicks_link
    def_delegators :current_scope, :fill_in,            :fills_in
    def_delegators :current_scope, :click_button,       :clicks_button
    def_delegators :current_scope, :select,             :selects
    def_delegators :current_scope, :check,              :checks
    def_delegators :current_scope, :choose,             :chooses
    def_delegators :current_scope, :uncheck,            :unchecks
    def_delegators :current_scope, :fire_event, :key_up, :key_down, :field_labeled

    def within(selector)
      scopes.push(::Webrat::Selenium::Scope.from_scope(self, current_scope, selector))
      ret = yield(current_scope)
      scopes.pop
      return ret
    end

    def current_scope
      scopes.last || page_scope
    end

    def page_scope
      ::Webrat::Selenium::Scope.from_page(self, response, response_body)
    end

    def scopes
      @_scopes ||= []
    end

    def xml_content_type?
      false
    end

    def current_dom #:nodoc:
      current_scope.dom
    end

    def elements
      {}
    end    

    def initialize(*args) # :nodoc:
    end

    def simulate
    end

    def automate
      yield
    end

    def visit(url)
      selenium.open(url)
    end

    webrat_deprecate :visits, :visit


    def response
      SeleniumResponse.new(self, response_body)
    end

    def response_body #:nodoc:
      selenium.get_html_source
    end

    def current_url
      selenium.location
    end







    def wait_for(params={})
      timeout = params[:timeout] || 5
      message = params[:message] || "Timeout exceeded"

      begin_time = Time.now

      while (Time.now - begin_time) < timeout
        value = nil

        begin
          value = yield
        rescue Exception => e
          unless is_ignorable_wait_for_exception?(e)
            raise e
          end
        end

        return value if value

        sleep 0.25
      end

      error_message = "#{message} (after #{timeout} sec)"

      if $browser
        error_message += <<-EOS


HTML of the page was:

#{selenium.get_html_source}"
EOS
      end

      raise Webrat::TimeoutError.new(error_message)
      true
    end

    def selenium
      return $browser if $browser
      setup
      $browser
    end

    webrat_deprecate :browser, :selenium


    def save_and_open_screengrab
      return unless File.exist?(Webrat.configuration.saved_pages_dir)

      filename = "#{Webrat.configuration.saved_pages_dir}/webrat-#{Time.now.to_i}.png"

      if $browser.chrome_backend?
        $browser.capture_entire_page_screenshot(filename, '')
      else
        $browser.capture_screenshot(filename)
      end
      open_in_browser(filename)

    end

    protected
    def is_ignorable_wait_for_exception?(exception) #:nodoc:
      if defined?(::Spec::Expectations::ExpectationNotMetError)
        return true if exception.class == ::Spec::Expectations::ExpectationNotMetError
      end
      return true if [::Selenium::CommandError, Webrat::WebratError].include?(exception.class)
      return false
    end

    def setup #:nodoc:
      Webrat::Selenium::SeleniumRCServer.boot
      Webrat::Selenium::ApplicationServerFactory.app_server_instance.boot

      create_browser
      $browser.start

      extend_selenium
      define_location_strategies
      $browser.window_maximize
    end


    def create_browser
      $browser = ::Selenium::Client::Driver.new(Webrat.configuration.selenium_server_address || "localhost",
      Webrat.configuration.selenium_server_port, Webrat.configuration.selenium_browser_key, "http://#{Webrat.configuration.application_address}:#{Webrat.configuration.application_port_for_selenium}")
      $browser.set_speed(0) unless Webrat.configuration.selenium_server_address

      at_exit do
        silence_stream(STDOUT) do
          $browser.stop
        end
      end
    end


    def extend_selenium #:nodoc:
      extensions_file = File.join(File.dirname(__FILE__), "selenium_extensions.js")
      extenions_js = File.read(extensions_file)
      selenium.get_eval(extenions_js)
    end

    def define_location_strategies #:nodoc:
      Dir[File.join(File.dirname(__FILE__), "location_strategy_javascript", "*.js")].sort.each do |file|
        strategy_js = File.read(file)
        strategy_name = File.basename(file, '.js')
        selenium.add_location_strategy(strategy_name, strategy_js)
      end
    end
  end
end
