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
            tap_permanent(target)
            add_counter("stun", to: target, amount: 3)
            draw_cards(2) if target.controller == controller
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
