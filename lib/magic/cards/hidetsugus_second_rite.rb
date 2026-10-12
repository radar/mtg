module Magic
  module Cards
    HidetsugusSecondRite = Instant("Hidetsugu's Second Rite") do
      cost generic: 3, red: 1
    end

    class HidetsugusSecondRite < Instant
      def target_choices
        game.players
      end

      def resolve!(target:)
        deal_damage(10, to: target) if target.life == 10
      end
    end
  end
end
