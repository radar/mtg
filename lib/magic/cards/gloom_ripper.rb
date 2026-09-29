module Magic
  module Cards
    GloomRipper = Creature("Gloom Ripper") do
      cost generic: 3, black: 2
      creature_type("Elf Assassin")
      power 4
      toughness 4
    end

    class GloomRipper < Creature
      # When this creature enters, target creature you control gets +X/+0 until end of turn and up
      # to one target creature an opponent controls gets -0/-X until end of turn, where X is the
      # number of Elves you control plus the number of Elf cards in your graveyard.
      class ETB < TriggeredAbility::EnterTheBattlefield
        class OpponentTargetChoice < Magic::Choice::Targeted
          def initialize(actor:, amount:)
            @amount = amount
            super(actor: actor)
          end

          def choices = battlefield.not_controlled_by(controller).creatures

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:modify_power_toughness, target: target, power: 0, toughness: -@amount, until_eot: true)
          end
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            x = controller.creatures.by_type("Elf").count + controller.graveyard.by_any_type("Elf").count
            trigger_effect(:modify_power_toughness, target: target, power: x, toughness: 0, until_eot: true)

            opponent_choice = OpponentTargetChoice.new(actor: actor, amount: x)
            game.add_choice(opponent_choice) if opponent_choice.choices.any?
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
