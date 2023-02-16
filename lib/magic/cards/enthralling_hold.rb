module Magic
  module Cards
    class EnthrallingHold < Aura
      # Enthralling Hold {3}{U}{U}
      # Enchantment — Aura
      # Enchant creature
      # You can't choose an untapped creature as this spell's target as you cast it.
      # You control enchanted creature.

      NAME = "Capture Sphere"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 3, blue: 2 }

      def target_choices
        battlefield.creatures.tapped
      end

      def resolve!(player, target:)
        target.controller = player

        super
      end
    end
  end
end
