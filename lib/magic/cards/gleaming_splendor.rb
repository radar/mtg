module Magic
  module Cards
    GleamingSplendor = Enchantment("Gleaming Splendor") do
      cost generic: 1, white: 1
    end

    class GleamingSplendor < Enchantment
      # "Whenever an opponent draws their second card each turn, you create a Treasure token."
      class SecondCardDrawTrigger < TriggeredAbility
        def should_perform?
          opponents.include?(event.player) &&
            game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 2
        end

        def call
          trigger_effect(:create_token, token_class: Tokens::Treasure, controller: controller)
        end
      end

      def event_handlers = super.merge({ Events::CardDraw => SecondCardDrawTrigger }) { |_, old, new| [*old, *new] }

      # "{2}{W}: Two target players each draw a card." In a two-player game the two targets can only be both
      # players, so there is nothing to choose.
      class DrawAbility < Magic::ActivatedAbility
        costs "{2}{W}"

        def resolve!
          game.players.each { |player| trigger_effect(:draw_cards, player: player, number_to_draw: 1) }
        end
      end

      def activated_abilities = [DrawAbility]
    end
  end
end
