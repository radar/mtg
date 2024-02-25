module Magic
  module Cards
    RambunctiousMutt = Creature("Rambunctious Mutt") do
      cost generic: 3, white: 2
      creature_type("Dog")
      keywords :deathtouch
      power 2
      toughness 2

      def target_choices
        battlefield.by_any_type("Artifact", "Enchantment").not_controlled_by(controller)
      end

      def resolve!(target:)
        if target
          trigger_effect(:destroy_target, target: target)
        end
      end
    end
  end
end
