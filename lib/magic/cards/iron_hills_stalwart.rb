module Magic
  module Cards
    IronHillsStalwart = Creature("Iron Hills Stalwart") do
      cost generic: 4, red: 1
      creature_type "Dwarf Warrior"
      power 4
      toughness 5
      keywords :reach, :trample
    end

    class IronHillsStalwart < Creature
      # "When this creature enters, attach target Equipment you control to up to one target creature you control."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class CreatureChoice < Magic::Choice::Targeted
          def initialize(equipment:, **args)
            super(**args)
            @equipment = equipment
          end

          def choices = creatures_you_control

          def choice_amount = 0..1

          def resolve!(target:)
            @equipment.attach_to!(target)
          end
        end

        class EquipmentChoice < Magic::Choice::Targeted
          def choices
            battlefield.controlled_by(controller).by_any_type("Equipment")
          end

          def choice_amount = 1

          def resolve!(target:)
            game.add_choice(CreatureChoice.new(actor: actor, equipment: target))
          end
        end

        def call
          choice = EquipmentChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
