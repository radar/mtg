module Magic
  module Cards
    DoranBesiegedByTime = Creature("Doran, Besieged by Time") do
      cost "{1}{W}{B}{G}"
      legendary_creature_type "Treefolk Druid"
      power 0
      toughness 5
    end

    class DoranBesiegedByTime < Creature
      # "Each creature spell you cast with toughness greater than its power costs {1}
      # less to cast."
      class ReduceCreatureCosts < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: -1 }
        end

        # Also asked about permanents (for their own characteristics); those are never spells.
        def applies_to?(card)
          card.is_a?(Magic::Card) && card.creature? && (card.controller || card.owner) == source.controller && card.base_toughness > card.base_power
        end
      end

      def static_abilities = [ReduceCreatureCosts]

      # "Whenever a creature you control attacks or blocks, it gets +X/+X until end of
      # turn, where X is the difference between its power and toughness."
      class AttacksOrBlocksTrigger < TriggeredAbility
        def creature
          event.respond_to?(:blocker) ? event.blocker : event.attacker
        end

        def should_perform?
          creature.controller == controller
        end

        def call
          difference = (creature.power - creature.toughness).abs
          trigger_effect(:modify_power_toughness, target: creature, power: difference, toughness: difference)
        end
      end

      def event_handlers
        {
          Events::CreatureAttacked => AttacksOrBlocksTrigger,
          Events::CreatureBlocked => AttacksOrBlocksTrigger
        }
      end
    end
  end
end
