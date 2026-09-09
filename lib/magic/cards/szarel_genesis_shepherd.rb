module Magic
  module Cards
    SzarelGenesisShepherd = Creature("Szarel, Genesis Shepherd") do
      legendary_creature_type "Insect Druid"
      cost generic: 2, black: 1, red: 1, green: 1
      power 3
      toughness 3
      keywords :flying
    end

    class SzarelGenesisShepherd < Creature
      class PermanentSacrificedTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor &&
            !event.permanent.token? &&
            event.permanent.controller == controller &&
            game.current_turn.active_player == controller
        end

        def call
          choices = controller.creatures.except(actor)
          game.add_choice(Choice.new(actor: actor, choices: choices)) unless choices.empty?
        end
      end

      class Choice < Magic::Choice
        attr_reader :choices

        def initialize(actor:, choices:)
          @choices = choices
          super(actor: actor)
        end

        def resolve!(target:)
          target.add_counter("+1/+1", amount: actor.power)
        end
      end

      def event_handlers
        { Events::PermanentSacrificed => PermanentSacrificedTrigger }
      end
    end
  end
end