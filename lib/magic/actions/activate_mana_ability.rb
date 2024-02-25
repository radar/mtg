module Magic
  module Actions
    class ActivateManaAbility < ActivateAbility
      def perform
        game.notify!(Events::AbilityActivated.new(ability: ability, player: player))
        resolve!
      end


      def choose(color)
        ability.choose(color)
      end
    end
  end
end
