module Magic
  module Counters
    def self.[](counter_type)
      return counter_type if counter_type.is_a?(Class)
      case counter_type
      when "+1/+1" then Plus1Plus1
      when "-1/-1" then Minus1Minus1
      when "lore" then Lore
      when "incarnation" then Incarnation
      when "page" then Page
      when "poison" then Poison
      else
        raise "Unknown counter type: #{counter_type}"
      end
    end
  end
end
