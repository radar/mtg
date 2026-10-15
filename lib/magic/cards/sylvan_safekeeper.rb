module Magic
  module Cards
    SylvanSafekeeper = Creature("Sylvan Safekeeper") do
      cost green: 1
      creature_type "Human Wizard"
      power 1
      toughness 1
    end

    class SylvanSafekeeper < Creature
      # Sacrifice a land: Target creature you control gains shroud until end of turn.
      class ShroudAbility < Magic::ActivatedAbility
        costs "Sacrifice a land"

        def target_choices = controller.creatures

        def resolve!(target:)
          give_keyword(target, :shroud)
        end
      end

      def activated_abilities = [ShroudAbility]
    end
  end
end
