module Magic
  module Cards
    BejeweledWarg = Creature("Bejeweled Warg") do
      cost generic: 1, green: 1
      creature_type("Wolf")
      keywords :trample
      power 3
      toughness 2
    end

    class BejeweledWarg < Creature
      # "choose one -- Put a +1/+1 counter on target Wolf you control. / Create a Treasure token."
      class ModeChoice < Magic::Choice
        def wolves = controller.creatures.select { _1.type?("Wolf") }

        def modes
          {
            counter: "Put a +1/+1 counter on target Wolf you control",
            treasure: "Create a Treasure token"
          }
        end

        # target: the Wolf for the counter mode (defaults to the first Wolf you control).
        def resolve!(mode:, target: nil)
          case mode
          when :counter
            target ||= wolves.first
            raise ArgumentError, "#{target&.name.inspect} is not a Wolf you control" unless wolves.include?(target)

            trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
          when :treasure
            trigger_effect(:create_token, token_class: Tokens::Treasure)
          else raise "Invalid mode chosen for Bejeweled Warg: #{mode}"
          end
        end
      end

      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.combat? && event.source == actor && event.target.player?
        end

        def call
          game.add_choice(ModeChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::DamageDealt => CombatDamageTrigger }
    end
  end
end
