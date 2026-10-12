module Magic
  module Cards
    MyPrecious = Equipment("My Precious") do
      legendary_artifact
      cost generic: 3
    end

    class MyPrecious < Equipment
      # Allure of Power {1}{B}, Instant -- Adventure
      adventure generic: 1, black: 1

      def adventure_instant? = true

      # "As an additional cost to cast this spell, sacrifice a creature."
      def adventure_additional_costs
        [Costs::Sacrifice.new(self, (controller || owner).creatures)]
      end

      # "Draw two cards."
      def adventure_resolve!(**)
        trigger_effect(:draw_cards, number_to_draw: 2)
      end

      # "Equip--{2}, Pay 2 life." Written out (rather than with the `equip` macro) because a life payment needs the
      # ability's source.
      class EquipAbility < Magic::ActivatedAbility
        costs "{2}, Pay 2 life"
        activate_only_as_sorcery

        def target_choices
          creatures_you_control
        end

        # So "Equip abilities that target this creature cost {2} less" (Dwarven Mauler) can tell it apart.
        def equip? = true

        def resolve!(target:)
          source.attach_to!(target)
        end
      end

      def activated_abilities = [EquipAbility]

      # "Equipped creature has hexproof and can't be blocked."
      class EquippedHexproof < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HEXPROOF
        applies_to_target
      end

      class EquippedCantBeBlocked < Abilities::Static::KeywordGrant
        keyword_grants Keywords::CANT_BE_BLOCKED
        applies_to_target
      end

      def static_abilities = [EquippedHexproof, EquippedCantBeBlocked]
    end
  end
end
