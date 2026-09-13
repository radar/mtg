module Magic
  module Cards
    class CrownOfSkemfar < Aura
      card_name "Crown of Skemfar"
      cost "{2}{G}{G}"

      def target_choices
        battlefield.creatures
      end

      def elves
        creatures_you_control.by_type("Elf").count
      end

      def power_modification = elves
      def toughness_modification = elves

      def keyword_grants
        [Keywords::REACH]
      end

      class ReturnFromGraveyard < Magic::ActivatedAbility
        costs "{2}{G}"

        def resolve!
          source.move_to_hand!
        end
      end

      def can_activate_ability?(ability)
        return true unless ability.is_a?(ReturnFromGraveyard)

        return true if self.zone == controller.graveyard

        false
      end

      def activated_abilities
        [ReturnFromGraveyard]
      end
    end
  end
end
