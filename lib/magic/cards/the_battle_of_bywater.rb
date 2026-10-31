module Magic
  module Cards
    class TheBattleOfBywater < Sorcery
      card_name "The Battle of Bywater"
      cost generic: 1, white: 2

      # "Destroy all creatures with power 3 or greater. Then create a Food token for each creature you control."
      def resolve!
        game.battlefield.creatures.select { _1.power >= 3 }.each { destroy(_1) }
        survivors = controller.creatures.count
        create_token(token: Tokens::Food, amount: survivors) if survivors.positive?
      end
    end
  end
end
