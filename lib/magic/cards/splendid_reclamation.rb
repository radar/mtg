module Magic
  module Cards
    class SplendidReclamation < Sorcery
      card_name "Splendid Reclamation"
      cost generic: 3, green: 1

      def resolve!
        controller.graveyard.lands.each { |land| land.resolve!(enters_tapped: true) }
      end
    end
  end
end
