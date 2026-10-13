module Magic
  module Cards
    BloodSeeker = Creature("Blood Seeker") do
      cost generic: 1, black: 1
      creature_type "Vampire Shaman"
      power 1
      toughness 1
    end

    class BloodSeeker < Creature
      class LoseLifeChoice < Magic::Choice::May
        def initialize(actor:, victim:)
          super(actor: actor)
          @victim = victim
        end

        def prompt = "Have #{@victim.name} lose 1 life?"

        def resolve!
          lose_life(@victim, 1)
        end
      end

      # "Whenever a creature an opponent controls enters, you may have that player lose 1 life."
      class CreatureEnteredTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          creature? && opponents.include?(event.permanent.controller)
        end

        def call
          game.add_choice(LoseLifeChoice.new(actor: actor, victim: event.permanent.controller))
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEnteredTrigger }
    end
  end
end
