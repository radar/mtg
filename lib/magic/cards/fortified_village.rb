module Magic
  module Cards
    FortifiedVillage = Card("Fortified Village") do
      type "Land"
    end

    class FortifiedVillage < Card
      def enters_tapped? = true

      class RevealChoice < Magic::Choice::Targeted
        def prompt = "Reveal a Forest or Plains card from your hand."

        def choices = hand.lands.by_any_type("Forest", "Plains")
        def choice_amount = 1

        def resolve!(target:)
          controller.reveal(target)
          actor.untap!
        end
      end

      class MayRevealChoice < Magic::Choice::May
        def prompt = "Reveal a Forest or Plains card from your hand to have Fortified Village enter untapped?"

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
        choices :green, :white
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
