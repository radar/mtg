module Magic
  module Cards
    EmissaryOfSoulfire = Creature("Emissary of Soulfire") do
      cost generic: 1, white: 1, blue: 1
      creature_type("Djinn Monk")
      power 1
      toughness 4
    end

    class EmissaryOfSoulfire < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 3
        end
      end

      # "Pay {E}{E}: Put an exalted counter on target creature you control. Activate only as a sorcery."
      class ExaltedCounterAbility < ActivatedAbility
        costs "Pay {E}{E}"
        activate_only_as_sorcery

        def single_target? = true

        def target_choices = controller.creatures

        def resolve!(target:)
          add_counter "exalted", to: target
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [ExaltedCounterAbility]
    end
  end
end
