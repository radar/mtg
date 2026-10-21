module Magic
  module Cards
    EtchedSlith = Creature("Etched Slith") do
      cost generic: 1, black: 1
      artifact_creature_type "Phyrexian Slith"
      power 1
      toughness 1
      keywords :menace
    end

    class EtchedSlith < Creature
      # Which kind of counter to remove, when the chosen permanent or opponent has more than one kind.
      class CounterTypeChoice < Magic::Choice
        attr_reader :target

        def initialize(actor:, target:)
          super(actor: actor)
          @target = target
        end

        def prompt = "Choose a kind of counter to remove."
        def choices = target.counters.map(&:class).uniq

        def resolve!(counter_type:)
          raise ArgumentError, "#{counter_type} is not on the target" unless choices.include?(counter_type)

          if target.is_a?(Magic::Player)
            target.counters.remove_first(counter_type)
          else
            target.take_counters!(counter_type)
            game.notify!(Events::CounterRemoved.new(permanent: target, counter_type:, amount: 1))
          end
        end

        # Mandatory once the target is chosen: remove the first kind.
        def decline!
          resolve!(counter_type: choices.first)
        end
      end

      # "When you do, you may remove a counter from another target permanent or opponent." Declining removes nothing.
      class RemoveCounterChoice < Magic::Choice::Targeted
        def prompt = "Choose another permanent or an opponent to remove a counter from."

        def choices
          permanents = battlefield.permanents.reject { _1.equal?(actor) }.select { _1.counters.any? }
          opponents = game.opponents(controller).select { _1.counters.any? }
          permanents + opponents
        end

        def choice_amount = 1

        def resolve!(target:)
          type_choice = CounterTypeChoice.new(actor: actor, target: target)
          kinds = type_choice.choices
          if kinds.one?
            type_choice.resolve!(counter_type: kinds.first)
          elsif kinds.any?
            game.choices.add(type_choice)
          end
        end

        def decline! = nil
      end

      # "Whenever this creature deals combat damage to a player, put a +1/+1 counter on it. When you do, you may remove
      # a counter from another target permanent or opponent."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.player?
        end

        def call
          # No counter is placed if it left the battlefield, so "when you do" does not happen.
          return unless game.battlefield.permanents.any? { _1.equal?(actor) }

          add_counter("+1/+1", to: actor)
          choice = RemoveCounterChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def event_handlers
        { Events::CombatDamageDealt => CombatDamageTrigger }
      end
    end
  end
end
