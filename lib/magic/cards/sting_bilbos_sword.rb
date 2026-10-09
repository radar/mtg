module Magic
  module Cards
    StingBilbosSword = Equipment("Sting, Bilbo's Sword") do
      legendary_artifact
      cost generic: 2
      keywords :flash
      equip [Costs::Mana.new(generic: 3)]
    end

    class StingBilbosSword < Equipment
      # "Each hone counter on an Equipment grants +1/+0 to equipped creature" is handled by Permanent#power_modification.

      # "Attach Sting to up to one target creature you control."
      class AttachChoice < Magic::Choice::Targeted
        def choices = controller.creatures

        def choice_amount = 0..1

        def resolve!(target: nil)
          actor.attach_to!(target) if target
        end
      end

      # "When Sting enters, put a hone counter on Sting for each creature target opponent controls. Attach Sting to up
      # to one target creature you control."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponent = game.opponents(controller).first
          creatures = opponent.creatures.count
          trigger_effect(:add_counter, counter_type: "hone", target: actor, amount: creatures) if creatures.positive?
          choice = AttachChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
