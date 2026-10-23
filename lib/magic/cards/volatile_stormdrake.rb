module Magic
  module Cards
    VolatileStormdrake = Creature("Volatile Stormdrake") do
      cost generic: 1, blue: 1
      creature_type "Drake"
      power 3
      toughness 2
      keywords :flying
    end

    class VolatileStormdrake < Creature
      # "Hexproof from activated and triggered abilities"
      def hexproof_from_abilities? = true

      # "...then sacrifice that creature unless you pay an amount of {E} equal to its mana value."
      class PayEnergyChoice < Magic::Choice::May
        def initialize(actor:, creature:, payer:)
          super(actor: actor)
          @creature = creature
          @payer = payer
        end

        attr_reader :creature, :payer

        def prompt = "Pay #{creature.mana_value} {E} to keep #{creature.name}?"

        def resolve!
          payer.pay_energy!(creature.mana_value)
        end

        def decline!
          creature.sacrifice!
        end
      end

      # "When this creature enters, exchange control of this creature and target creature an opponent controls. If you do,
      # you get {E}{E}{E}{E}, then sacrifice that creature unless you pay an amount of {E} equal to its mana value."
      class ExchangeChoice < Magic::Choice::Targeted
        def prompt = "Choose a creature an opponent controls to exchange control with."
        def choices = battlefield.creatures.select { _1.controller != actor.controller }
        def choice_amount = 1

        def resolve!(target:)
          return unless battlefield.permanents.include?(actor)

          mine = actor.controller
          theirs = target.controller
          actor.controller = theirs
          target.controller = mine
          gain_energy 4, to: mine
          if mine.energy >= target.mana_value
            game.add_choice(PayEnergyChoice.new(actor: actor, creature: target, payer: mine))
          else
            target.sacrifice!
          end
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          game.add_choice(ExchangeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
