module Magic
  module Costs
    module Parsers
      class Mana
        def self.parse(cost)
          symbols = {
            "W" => :white,
            "U" => :blue,
            "B" => :black,
            "R" => :red,
            "G" => :green
          }

          cost
            .scan(/{(.*?)}/)
            .flatten
            .group_by(&:itself)
            .map do |key, values|
              if key =~ /\d+/
                [:generic, key.to_i]
              else
                [symbols[key], values.count]
              end
            end.to_h
        end
      end
    end
  end
end
