module Magic
  module Cards
    CultivatorOfBlades = Creature("Cultivator of Blades") do
      cost "{3}{G}{G}"
      creature_type "Elf Artificer"
      power 1
      toughness 1
    end

    class CultivatorOfBlades < Creature
      ServoToken = Token.create("Servo") do
        type T::Artifact, T::Creature, T::Creatures["Servo"]
        power 1
        toughness 1
      end

      # Fabricate 2
      class FabricateChoice < Magic::Choice
        COUNTERS = :counters
        TOKENS = :tokens

        def resolve!(mode:)
          case mode
          when COUNTERS
            trigger_effect(:add_counter, target: actor, counter_type: "+1/+1", amount: 2)
          when TOKENS
            actor.trigger_effect(:create_token, token_class: ServoToken, amount: 2)
          end
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(FabricateChoice.new(actor: actor))
        end
      end

      class PumpChoice < Magic::Choice::May
        def initialize(actor:, power:, other_attackers:)
          @power = power
          @other_attackers = other_attackers
          super(actor: actor)
        end

        def resolve!
          @other_attackers.each do |attacker|
            attacker.trigger_effect(:modify_power_toughness, power: @power, toughness: @power, target: attacker, until_eot: true)
          end
        end
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          other_attackers = event.attacks.reject { |attack| attack.attacker == actor }.map(&:attacker)
          return if other_attackers.empty?

          game.choices.add(PumpChoice.new(actor: actor, power: actor.power, other_attackers: other_attackers))
        end
      end

      def etb_triggers = [ETB]

      def event_handlers
        { Events::FinalAttackersDeclared => AttackTrigger }
      end
    end
  end
end
