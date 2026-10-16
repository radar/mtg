module Magic
  module Cards
    RipplesOfUndeath = Enchantment("Ripples of Undeath") do
      cost generic: 1, black: 1
    end

    class RipplesOfUndeath < Enchantment
      # "Then you may pay {1} and 3 life. If you do, put a card from among those cards into your hand."
      # Accepting pays the mana and the life, then asks which milled card (still in the graveyard) to take.
      class PayChoice < Magic::Choice::PayMana
        attr_reader :milled

        def initialize(actor:, milled:)
          @milled = milled
          super(actor: actor, mana: { generic: 1 })
        end

        def can_pay? = super && chooser.life >= 3

        def resolve!(**args)
          super(**args)
          chooser.lose_life(3)
          cards = milled.select { _1.zone&.graveyard? }
          game.choices.add(Magic::Choice::ReturnFromAmong.new(actor: actor, cards: cards, filter: ->(_) { true })) if cards.any?
        end
      end

      class MainPhaseTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          milled = controller.mill(3)
          choice = PayChoice.new(actor: actor, milled: milled)
          game.choices.add(choice) if choice.can_pay?
        end
      end

      def event_handlers = { Events::FirstMainPhase => MainPhaseTrigger }
    end
  end
end
