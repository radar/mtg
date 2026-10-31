module Magic
  module Cards
    StewTheConeys = Instant("Stew the Coneys") do
      cost generic: 2, green: 1
    end

    class StewTheConeys < Instant
      def multi_target? = true

      # Slot one is a creature you control, slot two a creature you don't control.
      def target_choices
        [
          battlefield.creatures.controlled_by(controller),
          battlefield.creatures.not_controlled_by(controller),
        ]
      end

      # "Target creature you control deals damage equal to its power to target creature you don't control. Create a
      # Food token." One-sided: the second creature deals no damage back.
      def resolve!(targets:)
        mine, theirs = targets
        deal_damage(mine.power, to: theirs, source: mine)
        create_token(token: Tokens::Food)
      end
    end
  end
end
