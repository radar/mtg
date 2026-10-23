module Magic
  module Cards
    Six = Creature("Six") do
      legendary_creature_type "Treefolk"
      cost "{2}{G}"
      keywords :reach
      power 2
      toughness 4
    end

    class Six < Creature
      class LandToHandChoice < Magic::Choice::Targeted
        attr_reader :milled

        def initialize(milled:, **args)
          super(**args)
          @milled = milled
        end

        def choices = milled.select(&:land?)

        def choice_amount = 0..1

        def resolve!(target: nil)
          target&.move_to_hand!(actor.controller)
        end
      end

      # "Whenever Six attacks, mill three cards. You may put a land card from among them into your hand."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          milled = controller.mill(3)
          game.add_choice(LandToHandChoice.new(actor:, milled:)) if milled.any?(&:land?)
        end
      end

      # "During your turn, nonland permanent cards in your graveyard have retrace. (You may cast permanent cards from your
      # graveyard by discarding a land card in addition to paying their other costs.)"
      class RetraceGrant < StaticAbility
        def permits_casting_from_graveyard?(card, player)
          castable?(card, player)
        end

        def additional_cost_for(card, player)
          Costs::Discard.new(player, ->(c) { c.land? }) if card.zone&.graveyard? && castable?(card, player)
        end

        private

        def castable?(card, player)
          player == controller && game.current_turn.active_player == player && card.owner == player &&
            card.permanent? && !card.land?
        end
      end

      def static_abilities = [RetraceGrant]

      def event_handlers = { Events::CreatureAttacked => AttacksTrigger }
    end
  end
end
