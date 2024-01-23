module Magic
  module Cards
    class EnthrallingHold < Aura
      # Enthralling Hold {3}{U}{U}
      # Enchantment — Aura
      # Enchant creature
      # You can't choose an untapped creature as this spell's target as you cast it.
      # You control enchanted creature.

      NAME = "Enthralling Hold"
      COST = { generic: 3, blue: 2 }

      def target_choices
        battlefield.creatures.tapped
      end

      def resolve!(target:)
        target.controller = owner

        super
      end
    end
  end
end
