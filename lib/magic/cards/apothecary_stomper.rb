module Magic
  module Cards
    ApothecaryStomper = Creature("Apothecary Stomper") do
      cost generic: 4, green: 2
      creature_type("Elephant")
      keywords :vigilance
      power 4
      toughness 4
    end

    class ApothecaryStomper < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class Mode1 < TriggeredAbility::EnterTheBattlefield
          class TargetChoice < Magic::Choice::Targeted
            def choices
              battlefield.controlled_by(controller).creatures
            end

            def choice_amount = 1

            def resolve!(target:)
              trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 2)
            end
          end

          def call
            choice = TargetChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        class Mode2 < TriggeredAbility::EnterTheBattlefield
          def call
            trigger_effect(:gain_life, target: controller, life: 4)
          end
        end

        MODES = [Mode1, Mode2].freeze

        class ModeChoice < Magic::Choice
          def initialize(actor:, trigger:)
            super(actor:)
            @trigger = trigger
          end

          def choices = MODES.each_index.to_a

          def resolve!(mode:)
            MODES.fetch(mode).new(event: @trigger.event, actor:).call
          end
        end

        def call
          game.choices.add(ModeChoice.new(actor:, trigger: self))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
