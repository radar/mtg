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
          when "{T}"
            SelfTap.new(source)
          when /\A(?:\{[^}]+\})+\z/
            Mana.new(Costs::Parsers::Mana.parse(cost))
          when /\ASacrifice (?<amount>ten) nonland permanents\z/
            SacrificeNonlandPermanents.new(source, amount: 10)
          when /Sacrifice a creature with defender/
            Sacrifice.new(source, source.controller.creatures.select(&:defender?))
          when /Sacrifice another creature/
            SacrificeAnother.new(source, source.controller.creatures.reject { _1 == source })
          when /Sacrifice a creature/
            # TODO: Make this target only creatures controlled by player
            Sacrifice.new(source, source.controller.creatures)
          when /\ASacrifice a land\z/
            Sacrifice.new(source, source.controller.lands)
          when /\ASacrifice a Treasure\z/
            Sacrifice.new(source, source.controller.permanents.select { _1.type?("Treasure") })
          when /\ASacrifice an? (?<type>[A-Z][\w-]*)\z/
            # "Sacrifice an Elf": a creature of that type, which may be the source itself.
            Sacrifice.new(source, source.controller.creatures.by_type($~[:type]))
          when /\ARemove (?<amount>\d+) (?<type>[\w+\/-]+) counters? from {this}\z/
            RemoveCounter.new(source, Counters[$~[:type].downcase], amount: $~[:amount].to_i)
          when /\ABlight (?<amount>\d+)\z/
            Blight.new(source, amount: $~[:amount].to_i)
          when /\APay (?<amount>\d+) life\z/i
            PayLife.new(source, amount: $~[:amount].to_i)
          when /Sacrifice {this}/
            SelfSacrifice.new(source)
          when /Exile {this}/
            SelfExile.new(source)
          when /\ADiscard your hand\z/
            DiscardHand.new(source)
          when /Discard a card/
            Discard.new(source.controller)
          else
            raise "Unknown cost: #{cost}"
          end
        end
      end
    end
  end
end
