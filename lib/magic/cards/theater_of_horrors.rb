module Magic
  module Cards
    TheaterOfHorrors = Enchantment("Theater of Horrors") do
      cost generic: 1, black: 1, red: 1
    end

    class TheaterOfHorrors < Enchantment
      # "At the beginning of your upkeep, exile the top card of your library." The card is remembered as exiled with this
      # enchantment (`Permanent#exiled_cards`).
      class UpkeepTrigger < TriggeredAbility
        def should_perform? = event.player == controller

        def call
          card = controller.library.first
          return unless card

          card.exile!
          actor.exiled_cards << card
        end
      end

      # "During your turn, if an opponent lost life this turn, you may play lands and cast spells from among cards exiled with
      # this enchantment."
      class PlayExiledCards < StaticAbility
        def permits_casting_from_exile?(card, player)
          player == controller && game.current_turn.active_player == controller && card.zone&.exile? &&
            @source.exiled_cards.include?(card) && controller.opponents_life_lost_this_turn.positive?
        end
      end

      # "{3}{R}: This enchantment deals 1 damage to target opponent or planeswalker."
      class DamageAbility < Magic::ActivatedAbility
        costs "{3}{R}"

        def target_choices
          game.opponents(controller) + game.battlefield.not_controlled_by(controller).planeswalkers.to_a
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, source: source, target: target, damage: 1)
        end
      end

      def event_handlers = { Events::BeginningOfUpkeep => UpkeepTrigger }
      def static_abilities = [PlayExiledCards]
      def activated_abilities = [DamageAbility]
    end
  end
end
