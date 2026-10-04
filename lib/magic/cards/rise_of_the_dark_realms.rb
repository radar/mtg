module Magic
  module Cards
    RiseOfTheDarkRealms = Sorcery("Rise of the Dark Realms") do
      cost generic: 7, black: 2
    end

    class RiseOfTheDarkRealms < Sorcery
      def resolve!
        cards = game.graveyard_cards.select { _1.type?("Creature") }
        cards.each { trigger_effect(:return_target_from_graveyard_to_battlefield, target: _1, controller: controller) }
      end
    end
  end
end
