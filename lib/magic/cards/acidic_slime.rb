module Magic
  module Cards
    class AcidicSlime < Creature
      card_name "Acidic Slime"
      cost generic: 3, green: 2
      creature_type "Ooze"
      keywords :deathtouch
      power 2
      toughness 2

      def target_choices
        game.battlefield.cards.by_any_type("Artifact", "Enchantment", "Land")
      end

      def resolve!(target:)
        destroy(target)
      end
    end
  end
end
