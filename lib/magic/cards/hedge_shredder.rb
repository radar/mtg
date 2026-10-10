module Magic
  module Cards
    class HedgeShredder < Vehicle
      card_name "Hedge Shredder"
      cost generic: 2, green: 2
      power 5
      toughness 5
      crew 1

      # "Whenever this Vehicle attacks, you may mill two cards."
      class MillChoice < Magic::Choice::May
        def prompt = "Mill two cards?"

        def resolve!
          controller.mill(2)
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          game.choices.add(MillChoice.new(actor:))
        end
      end

      # "Whenever one or more land cards are put into your graveyard from your library, put them onto the battlefield
      # tapped." Mill is the only way cards go from library to graveyard here, so each milled land triggers
      # separately; the net result is the same.
      class MilledLandTrigger < TriggeredAbility
        def should_perform? = event.player == controller && event.card.land? && event.card.zone&.graveyard?

        def call
          land = event.card
          return unless land.zone&.graveyard?

          land.resolve!(enters_tapped: true)
        end
      end

      def event_handlers
        super.merge({ Events::CreatureAttacked => AttacksTrigger, Events::CardMilled => MilledLandTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
