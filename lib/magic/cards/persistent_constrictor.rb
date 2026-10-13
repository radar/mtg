module Magic
  module Cards
    PersistentConstrictor = Creature("Persistent Constrictor") do
      cost generic: 4, black: 1
      creature_type "Zombie Snake"
      power 5
      toughness 3
    end

    class PersistentConstrictor < Creature
      class TargetChoice < Magic::Choice::Targeted
        def prompt = "Put a -1/-1 counter on up to one target creature #{opponent.name} controls."

        attr_reader :opponent

        def initialize(actor:, opponent:)
          super(actor: actor)
          @opponent = opponent
        end

        def choices = battlefield.controlled_by(opponent).creatures.to_a

        def choice_amount = 1

        def optional? = true

        def resolve!(target:)
          add_counter("-1/-1", to: target)
        end
      end

      # "At the beginning of each opponent's upkeep, they lose 1 life and you put a -1/-1 counter on up to one target
      # creature they control."
      class UpkeepTrigger < TriggeredAbility
        def should_perform? = opponents.include?(event.player)

        def call
          lose_life event.player, 1
          choice = TargetChoice.new(actor: actor, opponent: event.player)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }

      # Persist
      def death_triggers = [DeathReturn::Persist]
    end
  end
end
