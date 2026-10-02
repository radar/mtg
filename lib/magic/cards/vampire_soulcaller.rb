module Magic
  module Cards
    VampireSoulcaller = Creature("Vampire Soulcaller") do
      cost generic: 4, black: 1
      creature_type("Vampire Warlock")
      keywords :flying
      power 3
      toughness 2
    end

    class VampireSoulcaller < Creature
      def can_block?(_) = false

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            controller.graveyard.cards.select { _1.type?("Creature") }
          end

          def choice_amount = 1

          def resolve!(target:)
            target.move_to_hand!
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
