module Magic
  module Cards
    SphinxOfForgottenLore = Creature("Sphinx of Forgotten Lore") do
      cost generic: 2, blue: 2
      creature_type("Sphinx")
      keywords :flash, :flying
      power 3
      toughness 3
    end

    class SphinxOfForgottenLore < Creature
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor }
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select { _1.instant? || _1.sorcery? }
          end

          def choice_amount = 1

          def resolve!(target:)
            target.grant_flashback_until_end_of_turn!
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
