module Magic
  module Cards
    DenethorRulingSteward = Creature("Denethor, Ruling Steward") do
      cost "{1}{W}{B}"
      legendary_creature_type "Human Noble"
      power 2
      toughness 4
    end

    class DenethorRulingSteward < Creature
      # "At the beginning of your end step, if a creature died under your control this turn, create a 1/1 white Human
      # Soldier creature token."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && game.current_turn.events.any? do |e|
            e.is_a?(Events::CreatureDied) && e.controller == controller
          end
        end

        def call
          create_token(token: Tokens::HumanSoldier)
        end
      end

      # "{2}, Sacrifice another creature: Each opponent loses 1 life and you gain 1 life."
      class DrainAbility < Magic::ActivatedAbility
        costs "{2}, Sacrifice another creature"

        def resolve!
          game.opponents(controller).each { |opponent| lose_life(opponent, 1) }
          gain_life 1
        end
      end

      def event_handlers = super.merge(Events::BeginningOfEndStep => EndStepTrigger)

      def activated_abilities = [DrainAbility]
    end
  end
end
