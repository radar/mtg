module Magic
  module Cards
    OrcishBowmasters = Creature("Orcish Bowmasters") do
      cost generic: 1, black: 1
      creature_type "Orc Archer"
      keywords :flash
      power 1
      toughness 1
    end

    class OrcishBowmasters < Creature
      # "...this creature deals 1 damage to any target. Then amass Orcs 1."
      class DamageChoice < Magic::Choice::Targeted
        def prompt = "Choose a target for Orcish Bowmasters to deal 1 damage to."

        def choices = game.any_target

        def choice_amount = 1

        def resolve!(target:)
          deal_damage(1, to: target)
          Magic::Amass.call(source: actor, controller: controller, amount: 1, subtype: "Orc")
        end
      end

      # "When this creature enters..."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(DamageChoice.new(actor: actor))
        end
      end

      # "...whenever an opponent draws a card except the first one they draw in each of their draw steps..."
      class DrawTrigger < TriggeredAbility
        def should_perform?
          event.player != controller && !first_draw_of_draw_step?
        end

        def call
          game.add_choice(DamageChoice.new(actor: actor))
        end

        private

        # The current CardDraw is already in the turn's events: it is the draw step's first draw when it is the only
        # draw by that player since the DrawStep event, and the step is still the draw step.
        def first_draw_of_draw_step?
          turn = game.current_turn
          return false unless turn.step?(:draw) && turn.active_player == event.player

          events = turn.events
          step_index = events.rindex { _1.is_a?(Events::DrawStep) }
          return false unless step_index

          events.drop(step_index).count { _1.is_a?(Events::CardDraw) && _1.player == event.player } == 1
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::CardDraw => DrawTrigger }
    end
  end
end
