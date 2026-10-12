module Magic
  module Cards
    class RabidBite < Sorcery
      card_name "Rabid Bite"
      cost generic: 1, green: 1

      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
      end

      # Target creature you control deals damage equal to its power to target creature you don't control.
      def resolve!(targets:)
        mine, theirs = targets
        mine.bite!(theirs)
      end
    end
  end
end
