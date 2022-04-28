module Magic
  module Cards
    SecureTheScene = Sorcery("Secure the Scene") do
      cost white: 1, generic: 4
    end

    class SecureTheScene < Sorcery
      def resolve!(targets:)
        add_effect("ExileTarget", choices: battlefield.creatures, targets: targets)

        token = Tokens::Soldier.new(game: game, controller: targets.first.controller)
        token.resolve!

        super()
      end
    end
  end
end
