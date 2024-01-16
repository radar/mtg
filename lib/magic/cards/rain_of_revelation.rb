module Magic
  module Cards
    RainOfRevelation = Instant("Rain of Revelation") do
      cost generic: 3, blue: 1
    end

    class RainOfRevelation < Instant
      def resolve!
        3.times { controller.draw! }

        game.choices.add(Magic::Choice::Discard.new(player: controller))
        super
      end
    end
  end
end
