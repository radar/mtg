module Magic
  module Cards
    class AuntiesSentence < Sorcery
      card_name "Auntie's Sentence"
      cost generic: 1, black: 1

      class RevealAndDiscard < Mode
        class DiscardChoice < Magic::Choice
          def initialize(actor:, player:)
            super(actor: actor)
            @player = player
          end

          def choices
            @player.hand.cards.reject(&:land?)
          end

          def resolve!(target:)
            target.discard!
          end
        end

        def target_choices
          game.opponents(controller)
        end

        def resolve!(target:)
          trigger_effect(:reveal_cards, target: target.hand.cards)
          choice = DiscardChoice.new(actor: self, player: target)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      class MinusTwoMinusTwo < Mode
        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target: target, power: -2, toughness: -2)
        end
      end

      modes RevealAndDiscard, MinusTwoMinusTwo
    end
  end
end
