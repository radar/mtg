module Magic
  module Cards
    class WearDown < Sorcery
      card_name "Wear Down"
      cost generic: 1, green: 1
      gift :card

      def multi_target? = true

      def distinct_targets? = true

      def target_choices
        pool = battlefield.by_any_type("Artifact", "Enchantment")
        Array.new(gift_promised? ? 2 : 1) { pool }
      end

      # Destroy target artifact or enchantment. If the gift was promised, instead destroy two target
      # artifacts and/or enchantments.
      def resolve!(targets:)
        targets.each { trigger_effect(:destroy_target, target: _1) }
      end
    end
  end
end
