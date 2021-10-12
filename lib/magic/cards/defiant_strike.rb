module Magic
  module Cards
    DefiantStrike = Instant("Defiant Strike") do
      cost white: 1
    end

    class DefiantStrike < Instant
      def resolve!
        apply_buff_effect = Effects::ApplyBuff.new(power: 1, choices: game.battlefield.creatures)
        game.add_effect(apply_buff_effect)

        draw_cards_effect = Effects::DrawCards.new(player: controller)
        game.add_effect(draw_cards_effect)
        super
      end
    end
  end
end
