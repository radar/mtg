module Magic
  module Cards
    HivespineWolverine = Creature("Hivespine Wolverine") do
      cost generic: 3, green: 2
      creature_type("Elemental Wolverine")
      power 5
      toughness 4
    end

    class HivespineWolverine < Creature
      # When this creature enters, choose one -- put a +1/+1 counter on target creature you control; this
      # creature fights target creature token; or destroy target artifact or enchantment.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def initialize(actor:, mode:)
            @mode = mode
            super(actor: actor)
          end

          def choices
            case @mode
            when :counter then battlefield.controlled_by(controller).creatures
            when :fight then battlefield.creatures.select(&:token?) - [actor]
            when :destroy then battlefield.by_any_type("Artifact", "Enchantment")
            end
          end

          def choice_amount = 1

          def resolve!(target:)
            case @mode
            when :counter then trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
            when :fight then actor.fights!(target)
            when :destroy then trigger_effect(:destroy_target, target: target)
            end
          end
        end

        class ModeChoice < Magic::Choice
          def choices = %i[counter fight destroy]

          def resolve!(mode:)
            raise ArgumentError, "choose a mode" unless choices.include?(mode)

            choice = TargetChoice.new(actor: actor, mode: mode)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          game.choices.add(ModeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
