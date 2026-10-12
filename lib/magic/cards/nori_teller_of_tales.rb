module Magic
  module Cards
    NoriTellerOfTales = Creature("Nori, Teller of Tales") do
      cost generic: 1, red_or_white: 1
      legendary_creature_type("Dwarf Bard")
      power 2
      toughness 2
    end

    class NoriTellerOfTales < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.creatures.attacking
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:grant_keyword, target: target, keyword: :first_strike)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
