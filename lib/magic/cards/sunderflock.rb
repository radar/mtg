module Magic
  module Cards
    Sunderflock = Creature("Sunderflock") do
      cost "{7}{U}{U}"
      creature_type "Elemental"
      power 5
      toughness 5
      keywords :flying
    end

    class Sunderflock < Creature
      # "This spell costs {X} less to cast, where X is the greatest mana value among
      # Elementals you control." Only the generic part can be reduced.
      def self_mana_cost_adjustment
        player = controller || owner
        {
          generic: -> {
            elementals = game.battlefield.controlled_by(player).select { |permanent| permanent.type?("Elemental") }
            -[elementals.map(&:mana_value).max.to_i, 7].min
          }
        }
      end

      # "When this creature enters, if you cast it, return all non-Elemental creatures to
      # their owners' hands."
      class ETB < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          super && actor.cast?
        end

        def call
          battlefield.creatures.reject { |creature| creature.type?("Elemental") }.each(&:return_to_hand)
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
