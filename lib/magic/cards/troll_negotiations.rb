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

        add_counter("+1/+1", to: mine, amount: 2)
        game.tick!

        mine.fights!(theirs)
      end
    end
  end
end
