module Magic
  module Cards
    RidersOfTheMark = Creature("Riders of the Mark") do
      cost generic: 6, red: 1
      creature_type "Human Knight"
      power 7
      toughness 4
      keywords :trample, :haste
    end

    class RidersOfTheMark < Creature
      # "Affinity for Humans": costs {1} less for each Human you control.
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -player.creatures.count { _1.type?("Human") } } }
      end

      # "At the beginning of your end step, if this creature attacked this turn, return it to its owner's hand. If you
      # do, create a number of 1/1 white Human Soldier creature tokens equal to its toughness."
      class EndStepTrigger < TriggeredAbility::BeginningOfEndStep
        def should_perform?
          controllers_end_step? && game.current_turn.events.any? do |e|
            e.is_a?(Events::CreatureAttacked) && e.attacker == actor
          end
        end

        def call
          toughness = actor.toughness
          return unless game.battlefield.permanents.include?(actor)

          bounce(actor)
          create_token(token: Tokens::HumanSoldier, amount: toughness)
        end
      end

      def event_handlers = super.merge(Events::BeginningOfEndStep => EndStepTrigger)
    end
  end
end
