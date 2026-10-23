module Magic
  module Cards
    GoldenTailTrainer = Creature("Golden-Tail Trainer") do
      cost generic: 1, green: 1, white: 1
      creature_type "Fox Samurai"
      power 1
      toughness 3
    end

    class GoldenTailTrainer < Creature
      # "Aura and Equipment spells you cast cost {X} less to cast, where X is this creature's power."
      class CostReduction < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          super(source:, adjustment: nil)
        end

        def adjustment = { generic: -source.power }

        def applies_to?(card)
          (card.controller || card.owner) == source.controller && (card.type?("Aura") || card.type?("Equipment"))
        end
      end

      def static_abilities = [CostReduction]

      # "Whenever this creature attacks, other modified creatures you control get +X/+X until end of turn, where X is
      # this creature's power."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          bonus = actor.power
          controller.creatures.select { _1 != actor && _1.modified? }.each { pump(_1, bonus, bonus) }
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttacksTrigger }
    end
  end
end
