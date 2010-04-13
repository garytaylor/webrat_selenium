module Webrat
  module Selenium
    module Matchers
      class HaveSelector
        def initialize(expected,options={})
          @expected = expected
          @options=options
          @occurences=0
        end

        def matches?(response)
          found=response.session.wait_for :timeout=>10 do
            response.selenium.is_element_present("css=#{@expected}")
          end
          if @options[:count]
            xpath=Nokogiri::CSS.parse(@expected.to_s).map do |ast|
              ast.to_xpath
            end.first
            @occurences=response.selenium.get_xpath_count(xpath)
            @occurences==@options[:count]
          else
            found
          end
          rescue Webrat::TimeoutError
            false
        end

        def does_not_match?(response)
          response.session.wait_for do
            !response.selenium.is_element_present("css=#{@expected}")
          end
          rescue Webrat::TimeoutError
            false
        end

        # ==== Returns
        # String:: The failure message.
        def failure_message
          if @options[:count]
            "expected following text to match selector #{@expected} #{@options[:count]} times, but found it #{@occurences} times:\n#{@document} "
          else
            "expected following text to match selector #{@expected}:\n#{@document}"
          end
        end

        # ==== Returns
        # String:: The failure message to be displayed in negative matches.
        def negative_failure_message
          "expected following text to not match selector #{@expected}:\n#{@document}"
        end
      end

      def have_selector(content,options={})
        HaveSelector.new(content,options)
      end

      # Asserts that the body of the response contains
      # the supplied selector
      def assert_have_selector(expected,options={})
        hs = HaveSelector.new(expected,options)
        assert hs.matches?(response), hs.failure_message
      end

      # Asserts that the body of the response
      # does not contain the supplied string or regepx
      def assert_have_no_selector(expected)
        hs = HaveSelector.new(expected)
        assert !hs.matches?(response), hs.negative_failure_message
      end
    end
  end
end
