module Webrat
  module Selenium
    class Field < ::Webrat::Selenium::Element
      attr_accessor :value
      def initialize(value)
        self.value=value
      end
    end
  end
end