module Magic
  module Cards
    RhovanionRampager = Creature("Rhovanion Rampager") do
      cost generic: 2, black: 1
      creature_type("Wolf")
      power 3
      toughness 2
    end

    class RhovanionRampager < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class SacrificeChoice < Magic::Choice::SacrificePermanent
          def resolve!(sacrifice: nil)
            sacrifice ||= candidates.first
            power = sacrifice.power
            super(sacrifice: sacrifice)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: power) if power.positive?
          end
        end

        def call
          choice = SacrificeChoice.new(actor: actor, type: "Creature", other: true)
          game.add_choice(choice) if choice.candidates.any?
        end
      end

      class DiesTrigger < TriggeredAbility::Death
        def call
          Magic::Amass.call(source: actor, controller: controller, amount: actor.power)
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
      def death_triggers = [DiesTrigger]
    end
  end
end
