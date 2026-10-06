module Magic
  module Cards
    class CrownOfSkemfar < Aura
      card_name "Crown of Skemfar"
      cost "{2}{G}{G}"

      enchant "Creature"

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

      # "{2}{G}: Return this card from your graveyard to your hand." Only usable from the graveyard, so it is listed as a
      # graveyard ability (instances), not an ordinary one.
      def graveyard_abilities
        [ReturnFromGraveyard.new(source: self)]
      end
    end
  end
end
