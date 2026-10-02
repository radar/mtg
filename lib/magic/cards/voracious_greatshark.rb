module Magic
  module Cards
    VoraciousGreatshark = Creature("Voracious Greatshark") do
      cost generic: 3, blue: 2
      creature_type("Shark")
      keywords :flash
      power 5
      toughness 4
    end

    class VoraciousGreatshark < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.stack.spells.select { _1.card.type?("Artifact") || _1.card.type?("Creature") }
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:counter_spell, target: target)
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
