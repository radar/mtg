module Magic
  module Cards
    PlayfulShove = Sorcery("Playful Shove") do
      cost generic: 1, red: 1
    end

    class PlayfulShove < Sorcery
      def target_choices
        game.any_target
      end

      def resolve!(target:)
        deal_damage(1, to: target)
        trigger_effect(:draw_card)
      end
    end
  end
end
