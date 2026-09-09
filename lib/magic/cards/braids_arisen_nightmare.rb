module Magic
  module Cards
    BraidsArisenNightmare = Creature("Braids, Arisen Nightmare") do
      legendary_creature_type "Nightmare"
      cost generic: 1, black: 2
      power 3
      toughness 3
    end

    class BraidsArisenNightmare < Creature
      class EndStepChoice < Magic::Choice::Targeted
        def choices
          controller.permanents
        end

        def resolve!(target:)
          target.sacrifice!
          opponents.each do |opponent|
            if opponent.permanents.any? { |permanent| permanent.any_type?(*target.types) }
              opponent.permanents.find { |permanent| permanent.any_type?(*target.types) }.sacrifice!
            else
              opponent.lose_life(2)
              controller.draw!
            end
          end
        end
      end

      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def call
          game.add_choice(EndStepChoice.new(actor: actor)) if controller.permanents.any?
        end
      end

      def event_handlers
        { Events::BeginningOfEndStep => EndStepTrigger }
      end
    end
  end
end