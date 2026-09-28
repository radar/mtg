module Magic
  module Cards
    Prismabasher = Creature("Prismabasher") do
      creature_type "Elemental"
      cost generic: 4, green: 2
      power 6
      toughness 6
      keywords :trample
    end

    class Prismabasher < Creature
      class TargetChoice < Magic::Choice::Targeted
        def choices
          battlefield.creatures.controlled_by(controller)
        end

        def choice_amount = 0..controller.colors_among_permanents

        def resolve!(targets:)
          x = controller.colors_among_permanents
          Array(targets).each do |target|
            trigger_effect(:modify_power_toughness, power: x, toughness: x, target: target, until_eot: true)
          end
        end
      end

      # Vivid -- When this creature enters, up to X target creatures you control get +X/+X until end of turn.
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
