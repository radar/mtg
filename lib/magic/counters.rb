module Magic
  module Counters
    def self.[](counter_name)
      case counter_name
      when "+1/+1"
        Plus1Plus1
      when "-1/-1"
        Minus1Minus1
      else
        raise "Unknown counter type: #{counter_name}"
      end
    end
  end
end
