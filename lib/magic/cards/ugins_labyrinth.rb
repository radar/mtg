module Magic
  module Cards
    UginsLabyrinth = Card("Ugin's Labyrinth") do
      type "Land"
    end

    class UginsLabyrinth < Card
      # "Imprint — When this land enters, you may exile a colorless card with mana value 7 or greater from your hand."
      class ImprintChoice < Magic::Choice
        def prompt = "Exile a colorless card with mana value 7 or greater from your hand."

        def choices = hand.select { _1.colorless? && _1.mana_value >= 7 }

        def resolve!(target:)
          actor.exile_with_this!(target)
        end

        def decline! = nil
      end

      class ImprintTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = ImprintChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "{T}: Add {C}. If a card is exiled with this land, add {C}{C} instead."
      class ManaAbility < Magic::TapManaAbility
        def mana_produced = { colorless: source.exiled_cards.any? ? 2 : 1 }
      end

      # "{T}: Return the exiled card to its owner's hand."
      class ReturnAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          source.exiled_cards.to_a.each do |card|
            card.move_to_hand!
            source.exiled_cards.delete(card)
          end
        end
      end

      def etb_triggers = [ImprintTrigger]

      def activated_abilities = [ManaAbility, ReturnAbility]
    end
  end
end
