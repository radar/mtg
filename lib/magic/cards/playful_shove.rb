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
        trigger_effect(:deal_damage, target: target, damage: 1)
        trigger_effect(:draw_card)
      end
    end
  end
end
