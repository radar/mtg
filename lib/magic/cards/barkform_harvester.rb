module Magic
  module Cards
    BarkformHarvester = Creature("Barkform Harvester") do
      type T::Artifact, T::Creature, "Shapeshifter"
      cost generic: 3
      keywords :changeling, :reach
      power 2
      toughness 3
    end

    class BarkformHarvester < Creature
      # {2}: Put target card from your graveyard on the bottom of your library.
      class BottomAbility < Magic::ActivatedAbility
        costs "{2}"

        def target_choices = controller.graveyard.cards

        def resolve!(target:)
          controller.graveyard.remove(target)
          target.zone = controller.library
          controller.library.add(target, controller.library.count)
        end
      end

      def activated_abilities = [BottomAbility]
    end
  end
end
