module Magic
  module Cards
    DisruptorFlute = Artifact("Disruptor Flute") do
      cost generic: 2
      keywords :flash
    end

    class DisruptorFlute < Artifact
      # "As this artifact enters, choose a card name."
      class NameChoice < Magic::Choice::CardName
        def prompt = "Choose a card name."

        def resolve!(choice:)
          actor.chosen_card_name = choice
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(NameChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      # "Spells with the chosen name cost {3} more to cast." Affects every player's spells.
      class IncreaseManaCost < Abilities::Static::ManaCostAdjustment
        def initialize(source:)
          @source = source
          @adjustment = { generic: 3 }
        end

        def applies_to?(card)
          name = source.chosen_card_name
          card.is_a?(Card) && name && card.name == name
        end
      end

      # "Activated abilities of sources with the chosen name can't be activated unless they're mana abilities."
      class ActivationLock < StaticAbility
        def prevents_activation?(ability)
          name = source.chosen_card_name
          name && ability.source.name == name
        end

        def source = @source
      end

      def static_abilities = [IncreaseManaCost, ActivationLock]
    end
  end
end
