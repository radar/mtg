module Magic
  module Cards
    KederektParasite = Creature("Kederekt Parasite") do
      cost black: 1
      creature_type "Horror"
      power 1
      toughness 1
    end

    class KederektParasite < Creature
      class DamageChoice < Magic::Choice::May
        def initialize(actor:, victim:)
          super(actor: actor)
          @victim = victim
        end

        def prompt = "Deal 1 damage to #{@victim.name}?"

        def resolve!
          trigger_effect(:deal_damage, source: actor, target: @victim, damage: 1)
        end
      end

      # "Whenever an opponent draws a card, if you control a red permanent, you may have this creature deal 1 damage to
      # that player."
      class CardDrawTrigger < TriggeredAbility
        def should_perform?
          opponents.include?(event.player) && controller.permanents.any? { _1.colors.include?(:red) }
        end

        def call
          game.add_choice(DamageChoice.new(actor: actor, victim: event.player))
        end
      end

      def event_handlers = { Events::CardDraw => CardDrawTrigger }
    end
  end
end
