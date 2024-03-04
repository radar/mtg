module Magic
  module Cards
    class ExperimentalOverload < Sorcery
      card_name "Experimental Overload"
      cost "{2}{U}{R}"

      class WeirdToken < Token
        token_name "Weird"
        colors :blue, :red
        creature_type "Weird"
      end

      class Choice < Magic::Choice::SearchGraveyard
        def choices
          controller.graveyard
        end

        def amount
          1
        end

        def resolve!(target:)
          target.move_to_hand!
        end
      end

      def resolve!
        weird_power = controller.graveyard.cards.count { |card| card.instant? || card.sorcery? }
        trigger_effect(
          :create_token,
          token_class: WeirdToken,
          base_power: weird_power,
          base_toughness: weird_power
        )

        game.choices.add(Choice.new(actor: self))
      end
    end
  end
end
