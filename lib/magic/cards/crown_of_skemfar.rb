module Magic
  module Cards
    class CrownOfSkemfar < Aura
      card_name "Crown of Skemfar"
      cost "{2}{G}{G}"

      def target_choices
        battlefield.creatures
      end

      def elves
        battlefield.controlled_by(owner).by_type("Elf").count
      end

      def power_modification
        elves
      end

      def toughness_modification
        elves
      end

      def keyword_grants
        [Keywords::REACH]
      end

      class ReturnFromGraveyard < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(generic: 2, green: 1)]

        def resolve!
          source.controller.graveyard.remove(source)
          source.controller.hand.add(source)
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
