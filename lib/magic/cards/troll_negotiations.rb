module Magic
  module Cards
    TrollNegotiations = Sorcery("Troll Negotiations") do
      cost generic: 2, green: 2

      def multi_target? = true

      def target_choices
        [
          battlefield.creatures.controlled_by(controller),
          battlefield.creatures.not_controlled_by(controller),
        ]
      end

      def resolve!(targets:)
        mine, theirs = targets

        trigger_effect(:add_counter, counter_type: "+1/+1", target: mine, amount: 2)
        game.tick!

        mine.fights!(theirs)
      end
    end
  end
end
