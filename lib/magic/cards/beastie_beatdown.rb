module Magic
  module Cards
    class BeastieBeatdown < Sorcery
      card_name "Beastie Beatdown"
      cost "{R}{G}"

      def multi_target? = true

      def target_choices
        [
          battlefield.creatures.controlled_by(controller),
          battlefield.creatures.not_controlled_by(controller),
        ]
      end

      # "Delirium — If there are four or more card types among cards in your graveyard, put two +1/+1 counters on the
      # creature you control. The creature you control deals damage equal to its power to the creature an opponent
      # controls."
      def resolve!(targets:)
        mine, theirs = targets
        if controller.graveyard.delirium?
          trigger_effect(:add_counter, counter_type: "+1/+1", source: mine, target: mine, amount: 2)
          game.tick!
        end
        trigger_effect(:deal_damage, source: mine, target: theirs, damage: mine.power)
      end
    end
  end
end
