module Magic
  module Cards
    RiddleGateGargoyle = Creature("Riddle Gate Gargoyle") do
      type T::Artifact, T::Creature, "Gargoyle"
      cost white: 1, blue: 1
      power 2
      toughness 2
      keywords :flying
    end

    class RiddleGateGargoyle < Creature
      # When this creature enters, you get {E}{E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 3
        end
      end

      # When you do, target creature you control gains lifelink until end of turn.
      class TargetChoice < Magic::Choice::Targeted
        def choices = battlefield.controlled_by(controller).creatures

        def choice_amount = 1

        def resolve!(target:)
          give_keyword(target, :lifelink)
        end
      end

      class PayChoice < Magic::Choice::PayEnergy
        def resolve!
          super
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # Whenever you attack, you may pay {E}{E}. When you do, ...
      class AttackTrigger < TriggeredAbility::YouAttack
        def call
          choice = PayChoice.new(actor: actor, amount: 2)
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        super.merge(AttackTrigger.handlers) { |_, old, new| [*old, *new] }
      end
    end
  end
end
