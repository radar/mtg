module Magic
  module Cards
    Lembas = Artifact("Lembas") do
      type T::Artifact, "Food"
      cost generic: 2
    end

    class Lembas < Artifact
      # "Scry 1, then draw a card." Declining the scry (`game.skip_choice!`) still draws.
      class ScryChoice < Magic::Choice::Scry
        def resolve!(**args)
          super
          draw_card
        end

        def decline! = draw_card
      end

      # "When this artifact enters, scry 1, then draw a card."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ScryChoice.new(actor: actor, amount: 1))
        end
      end

      # "When this artifact is put into a graveyard from the battlefield, its owner shuffles it into their library."
      class PutIntoGraveyardTrigger < TriggeredAbility::LeaveTheBattlefield
        def should_perform? = this? && event.to.graveyard? && !event.permanent.token?

        def call
          card = event.permanent.card
          return unless card.zone&.graveyard?

          game.add_effect(Effects::ShuffleIntoLibrary.new(source: card, target: card))
        end
      end

      # "{2}, {T}, Sacrifice this artifact: You gain 3 life."
      def activated_abilities = [Tokens::Food::GainLife]

      def etb_triggers = [EntersTrigger]

      def ltb_triggers = [PutIntoGraveyardTrigger]
    end
  end
end
