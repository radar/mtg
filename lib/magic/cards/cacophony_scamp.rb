module Magic
  module Cards
    CacophonyScamp = Creature("Cacophony Scamp") do
      creature_type "Phyrexian Goblin Warrior"
      cost red: 1
      power 1
      toughness 1
    end

    class CacophonyScamp < Creature
      class MaySacrificeChoice < Magic::Choice::May
        def resolve!
          actor.sacrifice!
          proliferate
        end
      end

      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.player?
        end

        def call
          game.choices.add(MaySacrificeChoice.new(actor: actor))
        end
      end

      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, damage:)
          @damage = damage
          super(actor: actor)
        end

        def choices = game.any_target

        def resolve!(target:)
          deal_damage(@damage, to: target)
        end
      end

      class DeathTrigger < TriggeredAbility::Death
        def call
          game.choices.add(DamageChoice.new(actor: actor, damage: actor.power))
        end
      end

      def event_handlers
        { Events::CombatDamageDealt => CombatDamageTrigger }
      end

      def death_triggers = [DeathTrigger]
    end
  end
end
