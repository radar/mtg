module Magic
  module Cards
    BrashTaunter = Creature("Brash Taunter") do
      creature_type "Goblin"
      cost generic: 4, red: 1
      power 1
      toughness 1
      keywords :indestructible
    end

    class BrashTaunter < Creature
      class OpponentDamageChoice < Magic::Choice::Targeted
        def initialize(actor:, damage:)
          @damage = damage
          super(actor: actor)
        end

        def choices = actor.opponents

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: @damage)
        end
      end

      class DamageDealtTrigger < TriggeredAbility
        def should_perform? = event.target == actor

        def call
          game.add_choice(OpponentDamageChoice.new(actor: actor, damage: event.damage))
        end
      end

      class FightAbility < ActivatedAbility
        costs "{2}{R}, {T}"

        def target_choices
          game.battlefield.creatures.except(source)
        end

        def resolve!(target:)
          source.trigger_effect(:deal_damage, target: target, damage: source.power)
          target.trigger_effect(:deal_damage, target: source, damage: target.power)
        end
      end

      def event_handlers
        { Events::DamageDealt => DamageDealtTrigger }
      end

      def activated_abilities = [FightAbility]
    end
  end
end
