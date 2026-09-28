module Magic
  module Cards
    class BurningCuriosity < Sorcery
      card_name "Burning Curiosity"
      cost generic: 2, red: 1

      def kicker_cost
        @blight_kicker_cost ||= Costs::BlightKicker.new(amount: 1)
      end

      def resolve!
        player = controller
        cards = player.library.first(kicker_cost.paid? ? 3 : 2)
        cards.each do |card|
          trigger_effect(:exile, target: card)
          game.play_permissions.grant_until_end_of_next_turn(card:, player:)
        end
      end
    end
  end
end
