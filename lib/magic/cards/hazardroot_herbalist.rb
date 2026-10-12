module Magic
  module Cards
    HazardrootHerbalist = Creature("Hazardroot Herbalist") do
      cost generic: 2, green: 1
      creature_type("Rabbit Druid")
      power 1
      toughness 4
    end

    class HazardrootHerbalist < Creature
      # Whenever you attack, target creature you control gets +1/+0 until end of turn. If that creature is a
      # token, it also gains deathtouch until end of turn.
      class AttackTrigger < TriggeredAbility::YouAttack
        class PumpChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            pump(target, 1, 0)
            trigger_effect(:grant_keyword, target: target, keyword: :deathtouch) if target.token?
          end
        end

        def call
          game.add_choice(PumpChoice.new(actor: actor))
        end
      end

      def event_handlers = super.merge(AttackTrigger.handlers)
    end
  end
end
