module Magic
  module Cards
    TidingsOfWar = Sorcery("Tidings of War") do
      cost red: 1
      flashback Costs::Mana.new(generic: 3, red: 1)
    end

    class TidingsOfWar < Sorcery
      # "Amass Goblins 1. If this spell was cast from a graveyard, amass Goblins 3 instead." A spell's card stays in
      # the zone it was cast from until it finishes resolving.
      def resolve!
        amount = zone&.graveyard? ? 3 : 1
        Magic::Amass.call(source: self, controller: controller, amount: amount)
        super
      end
    end
  end
end
