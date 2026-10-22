module Magic
  module Cards
    TuneTheNarrative = Instant("Tune The Narrative") do
      cost blue: 1
    end

    class TuneTheNarrative < Instant
      # Draw a card. You get {E}{E}.
      def resolve!
        draw_card
        gain_energy 2
        super
      end
    end
  end
end
