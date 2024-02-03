module Magic
  module Costs
    class Parser
      attr_reader :source, :costs

      def self.parse(source:, costs:)
        new(source:, costs:).parse
      end

      def initialize(source:, costs:)
        @source = source
        @costs = costs.split(",").map(&:strip)
      end

      def parse
        @costs.map do |cost|
          case cost
          when /\A\{[^T]}/
            Mana.new(Costs::Parsers::Mana.parse(cost))
          when "{T}"
            SelfTap.new(source)
          when /Sacrifice a creature/
            # TODO: Make this target only creatures controlled by player
            Sacrifice.new(source, source.controller.creatures)
          when /Sacrifice {this}/
            SelfSacrifice.new(source)
          else
            raise "Unknown cost: #{cost}"
          end
        end
      end
    end
  end
end
