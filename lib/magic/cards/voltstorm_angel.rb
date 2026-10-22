module Magic
  module Cards
    VoltstormAngel = Creature("Voltstorm Angel") do
      cost generic: 3, white: 2
      creature_type "Angel"
      power 4
      toughness 4
      keywords :flying
    end

    class VoltstormAngel < Creature
      # When this creature enters, you get {E}{E}{E}.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          gain_energy 3
        end
      end

      # When you do, choose one. A mandatory choice, so skipping it takes the first mode.
      class ModeChoice < Magic::Choice
        def prompt = "Choose one: this creature gains vigilance and lifelink, or other creatures you control get +1/+1"

        def modes
          {
            keywords: "This creature gains vigilance and lifelink until end of turn",
            pump: "Other creatures you control get +1/+1 until end of turn"
          }
        end

        def decline! = resolve!(mode: :keywords)

        def resolve!(mode:)
          case mode
          when :keywords
            give_keyword(actor, :vigilance)
            give_keyword(actor, :lifelink)
          when :pump
            controller.creatures.reject { _1 == actor }.each { pump(_1, 1, 1) }
          else
            raise "Invalid mode chosen for Voltstorm Angel: #{mode}"
          end
        end
      end

      class PayChoice < Magic::Choice::PayEnergy
        def resolve!
          super
          game.add_choice(ModeChoice.new(actor: actor))
        end
      end

      # At the beginning of combat on your turn, you may pay {E}{E}. When you do, choose one.
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          choice = PayChoice.new(actor: actor, amount: 2)
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::BeginningOfCombat => BeginningOfCombatTrigger }
    end
  end
end
