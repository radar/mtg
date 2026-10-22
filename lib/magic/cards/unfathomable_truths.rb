module Magic
  module Cards
    UnfathomableTruths = Instant("Unfathomable Truths") do
      cost generic: 4, blue: 1
      keywords :devoid
    end

    class UnfathomableTruths < Instant
      # "Draw three cards and create a 0/1 colorless Eldrazi Spawn creature token..."
      def resolve!
        draw_cards(3)
        create_eldrazi_spawn
      end
    end
  end
end
