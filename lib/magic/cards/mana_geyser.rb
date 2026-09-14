module Magic
  module Cards
    class ManaGeyser < Sorcery
      card_name "Mana Geyser"
      cost "{3}{R}{R}"

      def resolve!
        controller.add_mana(red: opponents.sum { |opponent| opponent.lands.tapped.count })
      end
    end
  end
end
