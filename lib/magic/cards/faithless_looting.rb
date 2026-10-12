module Magic
  module Cards
    FaithlessLooting = Sorcery("Faithless Looting") do
      cost red: 1
      flashback Costs::Mana.new(generic: 2, red: 1)
    end

    class FaithlessLooting < Sorcery
      def resolve!
        draw_cards(2)
        add_choice(:discard)
        add_choice(:discard)

        super
      end
    end
  end
end
