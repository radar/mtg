module Magic
  module Cards
    DragonhawkFatesTempest = Creature("Dragonhawk, Fate's Tempest") do
      legendary_creature_type "Bird Dragon"
      cost generic: 3, red: 2
      keywords :flying
      power 5
      toughness 5
    end

    class DragonhawkFatesTempest < Creature
      # At the beginning of your next end step, Dragonhawk deals 2 damage to each opponent for each of the cards
      # that are still exiled. A game-level listener that removes itself once it has fired.
      class EndStepDamage
        def initialize(game:, source:, player:, cards:)
          @game = game
          @source = source
          @player = player
          @cards = cards
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfEndStep) && event.active_player == @player

          @game.unsubscribe(self)
          remaining = @cards.count { _1.zone&.exile? }
          return if remaining.zero?

          @game.opponents(@player).each do |opponent|
            @source.trigger_effect(:deal_damage, target: opponent, damage: 2 * remaining)
          end
        end
      end

      # Whenever Dragonhawk enters or attacks, exile the top X cards of your library, where X is the number of
      # creatures you control with power 4 or greater. You may play those cards until your next end step. At the
      # beginning of your next end step, Dragonhawk deals 2 damage to each opponent for each of those cards that
      # are still exiled.
      module Exiling
        def exile_top_cards
          x = battlefield.controlled_by(controller).creatures.count { _1.power >= 4 }
          cards = controller.library.first(x)
          cards.each do |card|
            trigger_effect(:exile, target: card)
            game.play_permissions.grant_until_next_end_step(card: card, player: controller)
          end
          game.subscribe(EndStepDamage.new(game: game, source: actor, player: controller, cards: cards)) if cards.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        include Exiling

        def call = exile_top_cards
      end

      class AttacksTrigger < TriggeredAbility
        include Exiling

        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call = exile_top_cards
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
