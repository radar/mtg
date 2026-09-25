module Magic
  module Cards
    GalaGreeters = Creature("Gala Greeters") do
      cost "{1}{G}"
      creature_type "Elf Druid"
      power 1
      toughness 1
    end

    class GalaGreeters < Creature
      class AllianceChoice < Magic::Choice
        COUNTER = :counter
        TREASURE = :treasure
        LIFE = :life
        MODES = [COUNTER, TREASURE, LIFE].freeze

        def choices
          MODES.reject { |mode| actor.mode_chosen_this_turn?(mode) }
        end

        def resolve!(mode:)
          raise "Invalid or already-chosen mode for Gala Greeters" unless choices.include?(mode)

          actor.choose_mode_this_turn!(mode)

          case mode
          when COUNTER
            trigger_effect(:add_counter, target: actor, counter_type: "+1/+1")
          when TREASURE
            actor.trigger_effect(:create_token, token_class: Tokens::Treasure, enters_tapped: true)
          when LIFE
            controller.gain_life(2)
          end
        end
      end

      # Alliance -- Whenever another creature you control enters,
      # choose one that hasn't been chosen this turn.
      class AllianceTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor && event.permanent.creature? && event.permanent.controller == controller
        end

        def call
          choice = AllianceChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => AllianceTrigger }
      end
    end
  end
end
