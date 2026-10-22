module Magic
  module Cards
    CyclopsSuperconductor = Creature("Cyclops Superconductor") do
      cost "{1}{U}{R}"
      creature_type "Cyclops Wizard"
      power 2
      toughness 2
      keywords :prowess
    end

    class CyclopsSuperconductor < Creature
      # When this creature enters, you get {E}{E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 3
        end
      end

      # When you do, it deals damage equal to its power to any target.
      class DamageChoice < Magic::Choice::Targeted
        def initialize(actor:, damage:)
          @damage = damage
          super(actor: actor)
        end

        def choices = game.any_target

        def choice_amount = 1

        def resolve!(target:)
          deal_damage(@damage, to: target)
        end
      end

      class PayChoice < Magic::Choice::PayEnergy
        def initialize(actor:, amount:, damage:)
          @damage = damage
          super(actor: actor, amount: amount)
        end

        def resolve!
          super
          game.add_choice(DamageChoice.new(actor: actor, damage: @damage))
        end
      end

      # When this creature dies, you may pay {E}{E}{E}. When you do, it deals damage equal to its power to any target.
      class DiesTrigger < TriggeredAbility::Death
        def call
          choice = PayChoice.new(actor: actor, amount: 3, damage: actor.power)
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def etb_triggers = [EntersTrigger]

      def death_triggers = [DiesTrigger]
    end
  end
end
