module Magic
  module Cards
    ShriekingDrake = Creature("Shrieking Drake") do
      cost blue: 1
      creature_type "Drake"
      keywords :flying
      power 1
      toughness 1
    end

    class ShriekingDrake < Creature
      # "When this creature enters, return a creature you control to its owner's hand." Not targeted, and not
      # optional: skipping the choice returns the Drake itself.
      class ReturnChoice < Magic::Choice::Targeted
        def targets? = false

        def choices = battlefield.controlled_by(controller).creatures

        def choice_amount = 1

        def prompt = "Return a creature you control to its owner's hand."

        def resolve!(target:)
          bounce(target)
        end

        def decline!
          bounce(actor)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call = game.add_choice(ReturnChoice.new(actor: actor))
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
