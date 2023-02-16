module Magic
  module Cards
    class CaptureSphere < Aura
      NAME = "Capture Sphere"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 3, white: 1 }
      KEYWORDS = Keywords::FLASH

      def target_choices
        battlefield.creatures
      end

      def resolve!(player, target:)
        target.tap!

        super
      end

      def does_not_untap_during_untap_step?
        true
      end
    end
  end
end
