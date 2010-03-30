
module Webrat
  module Selenium
    class Scope < ::Webrat::Scope
      attr_accessor :selenium
      def self.from_page(session, response, response_body) #:nodoc:
        s=super
        s.selenium=session.selenium
        s
      end

      def self.from_scope(session, scope, selector) #:nodoc:
        s=super
        s.selenium=session.selenium
        s
      end

      def click_link(link_text_or_regexp, options = {})
        unless @selector
          if link_text_or_regexp.is_a?(Regexp)
            pattern = "evalregex:#{link_text_or_regexp.inspect}"
          else
            pattern = link_text_or_regexp.to_s
          end

          locator = "webratlink=#{pattern}"
          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.click locator
        else
          locator = "webratlinkwithin=#{@selector}|#{link_text_or_regexp}"
          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.click locator
        end

      end

      webrat_deprecate :clicks_link, :click_link

      def click_link_within(selector, link_text, options = {})
        unless @selector
          locator = "webratlinkwithin=#{selector}|#{link_text}"
          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.click locator
        else
          raise "Click link within is being used within a scope and it is not currently implemented.  Easy to do though"
        end
      end

      webrat_deprecate :clicks_link_within, :click_link_within

      def fill_in(field_identifier, options)
        unless @selector
          locator = "webrat=#{field_identifier}"
          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.type(locator, "#{options[:with]}")
        else
          raise "fill_in is being used within a scope and it is currently not implemented"
          #TODO:P2 Write the webratwithin location strategy
          locator = "webratwithin=#{@selector}|#{field_identifier}"
          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.type(locator, "#{options[:with]}")
        end
      end

      webrat_deprecate :fills_in, :fill_in

      def click_button(button_text_or_regexp = nil, options = {})
        if button_text_or_regexp.is_a?(Hash) && options == {}
          pattern, options = nil, button_text_or_regexp
        elsif button_text_or_regexp
          pattern = adjust_if_regexp(button_text_or_regexp)
        end
        pattern ||= '*'
        unless @selector
          locator = "button=#{pattern}"

          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.click locator
        else
          raise "click_button is being used within a scope and it is currently not implemented"
          #TODO Write buttonwithin location strategy to support this
          locator = "buttonwithin=#{@selector}|#{pattern}"

          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.click locator

        end
      end

      webrat_deprecate :clicks_button, :click_button

      def select(option_text, options = {})
        id_or_name_or_label = options[:from]
        unless @selector
          if id_or_name_or_label
            select_locator = "webrat=#{id_or_name_or_label}"
          else
            select_locator = "webratselectwithoption=#{option_text}"
          end

          selenium.wait_for_element select_locator, :timeout_in_seconds => 5
          selenium.select(select_locator, option_text)
        else
          raise "select is being used within a scope and it is currently not implemented"
          #TODO:P2 Write webratselectwithoptionwithin location strategy to support this
          if id_or_name_or_label
            select_locator = "webratwithin=#{@selector}|#{id_or_name_or_label}"
          else
            select_locator = "webratselectwithoptionwithin=#{@selector}|#{option_text}"
          end

          selenium.wait_for_element select_locator, :timeout_in_seconds => 5
          selenium.select(select_locator, option_text)

        end
      end

      webrat_deprecate :selects, :select

      def choose(label_text)
        unless @selector
          locator = "webrat=#{label_text}"
          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.click locator
        else
          raise "choose is being used within a scope and it is currently not implemented"
          #TODO - Test this
          locator = "webratwithin=#{@selector}|#{label_text}"
          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.click locator

        end
      end

      webrat_deprecate :chooses, :choose

      def check(label_text)
        unless @selector
          locator = "webrat=#{label_text}"
          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.click locator
        else
          raise "Check is being used within a scope and it is currently not implemented"
          locator = "webratwithin=#{@selector}|#{label_text}"
          selenium.wait_for_element locator, :timeout_in_seconds => 5
          selenium.click locator

        end
      end
      alias_method :uncheck, :check
      webrat_deprecate :checks, :check

      def fire_event(field_identifier, event)
        unless @selector
          locator = "webrat=#{Regexp.escape(field_identifier)}"
          selenium.fire_event(locator, "#{event}")
        else
          raise "fire_event is being used in a scope but it is currently not implemented"
          locator = "webratwithin=#{@selector}|#{Regexp.escape(field_identifier)}"
          selenium.fire_event(locator, "#{event}")
        end
      end

      def key_down(field_identifier, key_code)
        unless @selector
          locator = "webrat=#{Regexp.escape(field_identifier)}"
          selenium.key_down(locator, key_code)
        else
          raise "key_down is being used in a scope but it is currently not implemented"
          locator = "webratwithin=#{@selector}|#{Regexp.escape(field_identifier)}"
          selenium.key_down(locator, key_code)
        end
      end

      def key_up(field_identifier, key_code)
        unless @selector
          locator = "webrat=#{Regexp.escape(field_identifier)}"
          selenium.key_up(locator, key_code)
        else
          raise "key_up is being used in a scope but it is currently not implemented"
          locator = "webratwithin=#{@selector}|#{Regexp.escape(field_identifier)}"
          selenium.key_up(locator, key_code)
        end
      end

      def field_labeled(field_identifier)
        unless @selector
          locator="webrat=#{field_identifier}"
        else
          locator="webratwithin=#{@scope}|#{field_identifier}"
        end
        selenium.wait_for_element locator, :timeout_in_seconds=>5
        Selenium::Field.new(selenium.field locator)
        
      end

      protected
      def adjust_if_regexp(text_or_regexp) #:nodoc:
        if text_or_regexp.is_a?(Regexp)
          "evalregex:#{text_or_regexp.inspect}"
        else
          "evalregex:/#{text_or_regexp}/"
        end
      end
      
      
    end

  end
end