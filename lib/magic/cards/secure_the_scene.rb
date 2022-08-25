module Magic
  module Cards
    SecureTheScene = Sorcery("Secure the Scene") do
      cost white: 1, generic: 4
    end

    class SecureTheScene < Sorcery
      def target_choices
        battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(controller, target:)
        target.exile!

        Permanent.resolve(game: game, controller: target.controller, card: Tokens::Soldier.new)

        super
      end
    end
  end
end
