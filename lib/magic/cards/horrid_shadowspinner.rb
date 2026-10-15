module Magic
  module Cards
    HorridShadowspinner = Creature("Horrid Shadowspinner") do
      cost generic: 1, blue: 1, black: 1
      creature_type "Horror"
      power 2
      toughness 3
      keywords :lifelink
    end

    class HorridShadowspinner < Creature
      # "Whenever this creature attacks, you may draw cards equal to its power. If you do, discard that many cards."
      class DrawThenDiscard < Magic::Choice::May
        def resolve!(target: nil)
          count = actor.power
          return unless count.positive?

          draw_cards(count)
          discard = [count, controller.hand.count].min
          game.add_choice(Magic::Choice::Discard.new(player: controller, actor: actor, amount: discard)) if discard.positive?
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attack.attacker == actor

        def call
          game.add_choice(DrawThenDiscard.new(actor: actor)) if actor.power.positive?
        end
      end

      def event_handlers = { Events::AttackDeclared => AttacksTrigger }
    end
  end
end
