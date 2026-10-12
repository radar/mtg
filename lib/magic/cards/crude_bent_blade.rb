module Magic
  module Cards
    CrudeBentBlade = Equipment("Crude Bent Blade") do
      cost generic: 2, black: 1
      equip [Costs::Mana.new(generic: 2)]
    end

    class CrudeBentBlade < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 1
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class SacrificeChoice < Magic::Choice::Targeted
          def initialize(actor:, player:)
            @player = player
            super(actor: actor)
          end

          def targets? = false

          def choices
            battlefield.controlled_by(@player).by_any_type("Creature")
          end

          def choice_amount = 1

          def resolve!(target:)
            target.sacrifice!
          end
        end

        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.opponents(controller)
          end

          def choice_amount = 1

          def resolve!(target:)
            choice = SacrificeChoice.new(actor: actor, player: target)
            game.choices.add(choice) if choice.choices.any?
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
