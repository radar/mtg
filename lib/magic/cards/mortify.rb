module Magic
  module Cards
    Mortify = Instant("Mortify") do
      cost generic: 1, white: 1, black: 1
      type "Instant"
    end

    class Mortify < Instant
      def resolve!
        add_effect(
          "DestroyTarget",
          choices: battlefield.cards.by_any_type("Creature", "Enchantment")
        )
        super
      end
    end
  end
end
