module Magic
  module Cards
    # The land back face of Witch Enchanter. It has no mana cost.
    WitchBlessedMeadow = Card("Witch-Blessed Meadow") do
      type "Land"
    end

    class WitchBlessedMeadow < Card
      # "As this land enters, you may pay 3 life. If you don't, it enters tapped."
      def shock_life = 3

      class ManaAbility < Magic::TapManaAbility
        choices :white
      end

      def activated_abilities = [ManaAbility]
    end

    WitchEnchanter = Creature("Witch Enchanter") do
      cost generic: 3, white: 1
      creature_type "Human Warlock"
      power 2
      toughness 2
      back_face WitchBlessedMeadow
    end

    class WitchEnchanter < Creature
      # "When this creature enters, destroy target artifact or enchantment an opponent controls."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.not_controlled_by(controller).by_any_type("Artifact", "Enchantment")

          def choice_amount = 1

          def resolve!(target:)
            destroy(target)
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
