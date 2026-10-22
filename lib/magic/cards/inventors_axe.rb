module Magic
  module Cards
    InventorsAxe = Equipment("Inventor's Axe") do
      cost red: 1
      keywords :flash
      equip [Costs::PayEnergy.new(nil, amount: 2)]
    end

    class InventorsAxe < Equipment
      # Equipped creature gets +2/+0.
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 0
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff]

      # When this Equipment enters, you get {E}{E}.
      class EnergyTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 2
        end
      end

      # When this Equipment enters, attach it to target creature you control.
      class AttachTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            actor.attach_to!(target)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EnergyTrigger, AttachTrigger]
    end
  end
end
