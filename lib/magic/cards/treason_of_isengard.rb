module Magic
  module Cards
    TreasonOfIsengard = Sorcery("Treason of Isengard") do
      cost generic: 2, blue: 1
    end

    class TreasonOfIsengard < Sorcery
      # "Up to one target": one target slot, zero or one accepted.
      def multi_target? = true

      def target_choices
        [controller.graveyard.cards.select { _1.type?("Instant") || _1.type?("Sorcery") }]
      end

      # "Put up to one target instant or sorcery card from your graveyard on top of your library. Amass Orcs 2."
      def resolve!(targets: [])
        targets.each { |card| move_card(card, to: controller.library) if card.zone == controller.graveyard }
        Magic::Amass.call(source: self, controller: controller, amount: 2, subtype: "Orc")
        super()
      end
    end
  end
end
