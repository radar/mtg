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
        trigger_effect(:deal_damage, target: target, damage: 10) if target.life == 10
      end
    end
  end
end
