module Magic
  module Cards
    # The land back face of Pinnacle Monk. It has no mana cost.
    MysticPeak = Card("Mystic Peak") do
      type "Land"
    end

    class MysticPeak < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped."
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :red
      end

      def activated_abilities = [ManaAbility]
    end

    PinnacleMonk = Creature("Pinnacle Monk") do
      cost generic: 3, red: 2
      creature_type "Djinn Monk"
      power 2
      toughness 2
      keywords :prowess
      back_face MysticPeak
    end

    class PinnacleMonk < Creature
      # "When this creature enters, return target instant or sorcery card from your graveyard to your hand."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = graveyard.select { _1.instant? || _1.sorcery? }

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
