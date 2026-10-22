module Magic
  module Cards
    class OtterballAntics < Sorcery
      card_name "Otterball Antics"
      cost generic: 1, blue: 1
      flashback Costs::Mana.new(generic: 3, blue: 1)

      # Create a 1/1 blue and red Otter creature token with prowess. If this spell was cast from anywhere other
      # than your hand, put a +1/+1 counter on that creature.
      def resolve!
        from_hand = origin_zone.nil? || origin_zone.hand?
        otter = Tokens::Otter.new(game: game, owner: controller).resolve!
        otter.add_counter("+1/+1") if otter && !from_hand
      end
    end
  end
end
