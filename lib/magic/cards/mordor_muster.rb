module Magic
  module Cards
    MordorMuster = Sorcery("Mordor Muster") do
      cost generic: 1, black: 1
    end

    class MordorMuster < Sorcery
      # "You draw a card and you lose 1 life. Amass Orcs 1."
      def resolve!
        draw_card
        lose_life(controller, 1)
        Magic::Amass.call(source: self, controller: controller, amount: 1, subtype: "Orc")
        super
      end
    end
  end
end
