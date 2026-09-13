module Magic
  module Cards
    ShineshadowSnarl = Card("Shineshadow Snarl") do
      type "Land"
    end

    class ShineshadowSnarl < Card
      def enters_tapped? = true

      class RevealChoice < Magic::Choice::Targeted
        def choices = hand.lands.by_any_type("Plains", "Swamp")
        def choice_amount = 1

        def resolve!(target:)
          controller.reveal(target)
          actor.untap!
        end
      end

      class MayRevealChoice < Magic::Choice::May
        def resolve!
          game.choices.add(RevealChoice.new(actor: actor))
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = RevealChoice.new(actor: actor)
          game.choices.add(MayRevealChoice.new(actor: actor)) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      class ManaAbility < Magic::TapManaAbility
        choices :white, :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
