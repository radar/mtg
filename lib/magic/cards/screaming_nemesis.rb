module Magic
  module Cards
    ScreamingNemesis = Creature("Screaming Nemesis") do
      cost generic: 2, red: 1
      creature_type "Spirit"
      keywords :haste
      power 3
      toughness 3
    end

    class ScreamingNemesis < Creature
      # "Whenever this creature is dealt damage, it deals that much damage to any other target. If a player is dealt
      # damage this way, they can't gain life for the rest of the game."
      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, damage:)
          @damage = damage
          super(actor: actor)
        end

        def prompt = "Screaming Nemesis deals #{@damage} damage to any other target."

        def choices = game.any_target - [actor]

        def choice_amount = 1

        def resolve!(target:)
          deal_damage(@damage, to: target)
          target.cant_gain_life! if target.is_a?(Magic::Player)
        end
      end

      class DamageTrigger < TriggeredAbility
        def should_perform?
          event.target == actor && event.damage.positive?
        end

        def call
          game.add_choice(DamageChoice.new(actor: actor, damage: event.damage))
        end
      end

      def event_handlers = { Events::DamageDealt => DamageTrigger }
    end
  end
end
