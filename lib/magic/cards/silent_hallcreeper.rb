module Magic
  module Cards
    SilentHallcreeper = Creature("Silent Hallcreeper") do
      cost generic: 1, blue: 1
      type T::Enchantment, T::Creature, *creature_types("Horror")
      power 1
      toughness 1
    end

    class SilentHallcreeper < Creature
      # "This creature can't be blocked."
      def can_be_blocked?(_) = false

      # "This creature becomes a copy of another target creature you control."
      class CopyChoice < Magic::Choice::Targeted
        def choices = controller.creatures.reject { |creature| creature.equal?(actor) }

        def choice_amount = 1

        def resolve!(target:)
          actor.copied_card = target.copiable_card
          actor.apply_continuous_effects!
        end
      end

      class ModeChoice < Magic::Choice
        COUNTERS = :counters
        DRAW = :draw
        COPY = :copy
        MODES = [COUNTERS, DRAW, COPY].freeze

        def choices
          MODES.reject { |mode| actor.mode_chosen?(mode) || (mode == COPY && copy_targets.empty?) }
        end

        def resolve!(mode:)
          raise "Invalid or already-chosen mode for Silent Hallcreeper" unless choices.include?(mode)

          actor.choose_mode!(mode)

          case mode
          when COUNTERS
            trigger_effect(:add_counter, target: actor, counter_type: "+1/+1", amount: 2)
          when DRAW
            controller.draw!
          when COPY
            copy_choice = CopyChoice.new(actor: actor)
            game.choices.add(copy_choice) if copy_choice.choices.size > 1
            copy_choice.resolve!(target: copy_choice.choices.first) if copy_choice.choices.size == 1
          end
        end

        private

        def copy_targets = controller.creatures.reject { |creature| creature.equal?(actor) }
      end

      # "Whenever this creature deals combat damage to a player, choose one that hasn't been chosen."
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.player?
        end

        def call
          choice = ModeChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def event_handlers
        { Events::CombatDamageDealt => CombatDamageTrigger }
      end
    end
  end
end
