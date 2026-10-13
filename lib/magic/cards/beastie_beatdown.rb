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
          add_counter "+1/+1", to: mine, amount: 2, source: mine
          game.tick!
        end
        deal_damage mine.power, to: theirs, source: mine
      end
    end
  end
end
