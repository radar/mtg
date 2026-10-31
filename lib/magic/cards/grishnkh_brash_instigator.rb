module Magic
  module Cards
    GrishnkhBrashInstigator = Creature("Grishnákh, Brash Instigator") do
      cost generic: 2, red: 1
      legendary_creature_type "Goblin Soldier"
      power 1
      toughness 1
    end

    class GrishnkhBrashInstigator < Creature
      # "When you do, until end of turn, gain control of target nonlegendary creature an opponent controls with power
      # less than or equal to the amassed Army's power. Untap that creature. It gains haste until end of turn."
      # The Army's power is read both when targets are chosen and when the reflexive trigger resolves.
      class StealChoice < Magic::Choice::Targeted
        def initialize(actor:, army:)
          @army = army
          super(actor: actor)
        end

        def choice_amount = 1

        def choices
          game.opponents(controller).flat_map { _1.creatures.to_a }.select { legal?(_1) }
        end

        def resolve!(target:)
          return unless legal?(target)

          target.gain_control_until_eot!(controller)
          target.untap!
          give_keyword(target, :haste)
        end

        def decline! = nil

        private

        def legal?(creature)
          @army.apply_continuous_effects!
          !creature.legendary? && creature.power <= @army.power
        end
      end

      # "When Grishnákh enters, amass Orcs 2. When you do, ..."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = event.permanent == actor

        def call
          army = Magic::Amass.call(source: actor, controller: controller, amount: 2, subtype: "Orc")
          return unless army

          choice = StealChoice.new(actor: actor, army: army)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
