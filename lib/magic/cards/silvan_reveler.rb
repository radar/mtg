module Magic
  module Cards
    SilvanReveler = Creature("Silvan Reveler") do
      cost generic: 2, green: 1, blue: 1
      creature_type("Elf Citizen")
      power 3
      toughness 2
    end

    class SilvanReveler < Creature
      # "...draw a card, then discard a card. If you discard a land card this way, put it from your graveyard onto
      # the battlefield tapped."
      class DiscardChoice < Magic::Choice::Discard
        def resolve!(card: nil, cards: nil)
          chosen = cards || [card]
          super
          chosen.each { _1.resolve!(enters_tapped: true) if _1.land? && _1.zone&.graveyard? }
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.draw!
          game.add_choice(DiscardChoice.new(player: controller, actor: actor)) if controller.hand.any?
        end
      end

      # "Landfall -- Whenever a land you control enters, you may pay {1}{G}{U}. If you do, return this card from your
      # graveyard to your hand."
      class ReturnChoice < Magic::Choice::PayMana
        def chooser = actor.owner

        def resolve!(**args)
          super(**args)
          actor.move_to_hand! if actor.zone&.graveyard?
        end
      end

      class LandfallTrigger < TriggeredAbility::Landfall
        def self.works_from_graveyard? = true

        def should_perform?
          actor.zone&.graveyard? && event.player == actor.owner
        end

        def call
          choice = ReturnChoice.new(actor: actor, mana: { generic: 1, green: 1, blue: 1 })
          game.add_choice(choice) if choice.can_pay?
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge({ Events::Landfall => LandfallTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
