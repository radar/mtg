module Magic
  module Cards
    RakdosLordOfRiots = Creature("Rakdos, Lord of Riots") do
      cost black: 2, red: 2
      legendary_creature_type "Demon"
      keywords :flying, :trample
      power 6
      toughness 6
    end

    class RakdosLordOfRiots < Creature
      # "You can't cast Rakdos unless an opponent lost life this turn."
      def cast_prohibited_reason(player)
        return if player.opponents_life_lost_this_turn.positive?

        "#{name} can't be cast unless an opponent lost life this turn"
      end

      # "Creature spells you cast cost {1} less to cast for each 1 life your opponents have lost this turn."
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: {})
        end

        def adjustment = { generic: -source.controller.opponents_life_lost_this_turn }

        def applies_to?(card)
          (card.controller || card.owner) == source.controller && card.creature?
        end
      end

      def static_abilities = [CostReduction]
    end
  end
end
