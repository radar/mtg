module Magic
  module Abilities
    module Static
      class ReduceManaCost
        attr_reader :reduction, :applies_to
        def initialize(reduction:, applies_to:)
          @reduction = reduction
          @applies_to = applies_to
        end

        def applies_to?(card)
          applies_to.call(card)
        end

        def apply(cost)
          @reduction.each do |mana, count|
            cost[mana] -= count
          end
        end
      end
    end
  end
end
