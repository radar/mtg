module Magic
  module Cards
    DreamdewEntrancer = Creature("Dreamdew Entrancer") do
      cost "{2}{G}{U}"
      creature_type("Frog Wizard")
      keywords :reach
      power 3
      toughness 4
    end

    class DreamdewEntrancer < Creature
      # When this creature enters, tap up to one target creature and put three stun counters on it. If you
      # control that creature, draw two cards.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TapChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:tap, target: target)
            trigger_effect(:add_counter, counter_type: "stun", target: target, amount: 3)
            trigger_effect(:draw_cards, number_to_draw: 2) if target.controller == controller
          end
        end

        def call
          choice = TapChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
