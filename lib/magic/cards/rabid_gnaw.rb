module Magic
  module Cards
    class RabidGnaw < Instant
      card_name "Rabid Gnaw"
      cost generic: 1, red: 1

      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
      end

      # Target creature you control gets +1/+0 until end of turn. Then it deals damage equal to its power to
      # target creature you don't control.
      def resolve!(targets:)
        mine, theirs = targets
        trigger_effect(:modify_power_toughness, power: 1, toughness: 0, target: mine, until_eot: true)
        game.tick!
        mine.bite!(theirs)
      end
    end
  end
end
