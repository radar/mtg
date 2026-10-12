module Magic
  module Cards
    class LongstalkBrawl < Sorcery
      card_name "Longstalk Brawl"
      cost green: 1
      gift :tapped_fish

      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
      end

      # Choose target creature you control and target creature you don't control. Put a +1/+1 counter
      # on the creature you control if the gift was promised. Then those creatures fight each other.
      def resolve!(targets:)
        mine, theirs = targets
        trigger_effect(:add_counter, counter_type: "+1/+1", target: mine, amount: 1) if gift_promised?
        mine.fights!(theirs)
      end
    end
  end
end
