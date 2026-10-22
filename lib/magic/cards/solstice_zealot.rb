module Magic
  module Cards
    SolsticeZealot = Creature("Solstice Zealot") do
      cost generic: 2, white: 1
      creature_type "Rhino Cleric"
      power 2
      toughness 3
    end

    class SolsticeZealot < Creature
      # When this creature enters, you get {E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
        end
      end

      # {T}, Pay {E}: Tap target creature.
      class TapAbility < Magic::ActivatedAbility
        costs "{T}, Pay {E}"

        def target_choices = battlefield.creatures

        def resolve!(target:)
          tap_permanent(target)
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [TapAbility]
    end
  end
end
