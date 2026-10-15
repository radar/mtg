module Magic
  module Cards
    WirewoodSymbiote = Creature("Wirewood Symbiote") do
      cost green: 1
      creature_type "Insect"
      power 1
      toughness 1
    end

    class WirewoodSymbiote < Creature
      # Return an Elf you control to its owner's hand: Untap target creature. Activate only once each turn.
      class UntapAbility < Magic::ActivatedAbility
        costs "Return an Elf you control to its owner's hand"
        once_each_turn

        def target_choices = game.battlefield.creatures

        def resolve!(target:)
          target.untap!
        end
      end

      def activated_abilities = [UntapAbility]
    end
  end
end
