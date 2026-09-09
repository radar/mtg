module Magic
  module Cards
    KorvoldFaeCursedKing = Creature("Korvold, Fae-Cursed King") do
      legendary_creature_type "Dragon Noble"
      cost generic: 2, black: 1, red: 1, green: 1
      power 4
      toughness 4
      keywords :flying, :trample
    end

    class KorvoldFaeCursedKing < Creature
      class SacrificeChoice < Magic::Choice::Targeted
        def choice_amount = 1

        def choices
          actor.controller.permanents.except(actor)
        end

        def resolve!(target:)
          target.sacrifice!
        end
      end

      class EntersOrAttacksTrigger < TriggeredAbility
        def should_perform?
          (event.is_a?(Events::EnteredTheBattlefield) && event.permanent == actor) ||
            (event.is_a?(Events::FinalAttackersDeclared) && event.attacks.any? { |attack| attack.attacker == actor })
        end

        def call
          choices = SacrificeChoice.new(actor: actor)
          game.add_choice(choices) if choices.choices.any?
        end
      end

      class PermanentSacrificedTrigger < TriggeredAbility
        def call
          actor.add_counter("+1/+1")
          controller.draw!
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => EntersOrAttacksTrigger,
          Events::FinalAttackersDeclared => EntersOrAttacksTrigger,
          Events::PermanentSacrificed => PermanentSacrificedTrigger,
        }
      end
    end
  end
end