module Magic
  module Cards
    BonePitBrute = Creature("Bone Pit Brute") do
      cost generic: 4, red: 2
      creature_type "Cyclops"
      keywords :menace
      power 4
      toughness 5
    end

    class BonePitBrute < Creature
      class PumpChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:modify_power_toughness, target:, power: 4, toughness: 0)
        end
      end

      # "When this creature enters, target creature gets +4/+0 until end of turn."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(PumpChoice.new(actor:))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
