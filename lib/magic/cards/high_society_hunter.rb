module Magic
  module Cards
    HighSocietyHunter = Creature("High-Society Hunter") do
      cost generic: 3, black: 2
      creature_type("Vampire Noble")
      keywords :flying
      power 5
      toughness 3
    end

    class HighSocietyHunter < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class SacrificeChoice < Magic::Choice::SacrificePermanent
          def resolve!(sacrifice: nil)
            super
            trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
          end
        end

        def call
          game.choices.add(SacrificeChoice.new(actor: actor, type: "Creature", other: true)) if Magic::Choice::SacrificePermanent.new(actor: actor, type: "Creature", other: true).candidates.any?
        end
      end

      class CreatureDiesTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor && !event.permanent.token?
        end

        def call
          trigger_effect(:draw_card)
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger, Events::CreatureDied => CreatureDiesTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
