module Magic
  module Cards
    Electrozoa = Creature("Electrozoa") do
      cost generic: 2, blue: 1
      creature_type "Jellyfish"
      power 3
      toughness 1
      keywords :flash, :flying
    end

    class Electrozoa < Creature
      # When this creature enters, you get {E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
        end
      end

      # Tap this creature unless you pay {E}. Declining (or having no energy) taps it.
      class UpkeepChoice < Magic::Choice::PayEnergy
        def decline!
          tap_permanent actor
        end
      end

      # At the beginning of your first main phase, tap this creature unless you pay {E}.
      class FirstMainPhaseTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          choice = UpkeepChoice.new(actor: actor)
          choice.can_pay? ? game.add_choice(choice) : choice.decline!
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge({ Events::FirstMainPhase => FirstMainPhaseTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
