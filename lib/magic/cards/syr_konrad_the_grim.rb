module Magic
  module Cards
    SyrKonradTheGrim = Creature("Syr Konrad, the Grim") do
      cost generic: 3, black: 2
      legendary_creature_type "Human Knight"
      power 5
      toughness 4
    end

    class SyrKonradTheGrim < Creature
      module Ping
        def ping
          opponents.each { |opponent| actor.trigger_effect(:deal_damage, source: actor, target: opponent, damage: 1) }
        end
      end

      # "Whenever another creature dies, ... Syr Konrad deals 1 damage to each opponent."
      class CreatureDiedTrigger < TriggeredAbility
        include Ping

        def should_perform? = event.permanent != actor

        def call = ping
      end

      # "... or a creature card is put into a graveyard from anywhere other than the battlefield, ..."
      class CardEnteredGraveyardTrigger < TriggeredAbility
        include Ping

        # A permanent that died reaches the graveyard as a card with no `from` zone (`CreatureDied` already covered it).
        def should_perform?
          event.to.graveyard? && event.from && !event.from.battlefield? && event.card.creature?
        end

        def call = ping
      end

      # "... or a creature card leaves your graveyard, ..."
      class CardLeftGraveyardTrigger < TriggeredAbility
        include Ping

        def should_perform?
          event.from&.graveyard? && event.from.owner == controller && event.card.creature?
        end

        def call = ping
      end

      # "{1}{B}: Each player mills a card."
      class MillAbility < Magic::ActivatedAbility
        costs "{1}{B}"

        def resolve!
          game.players.each { _1.mill(1) }
        end
      end

      def activated_abilities = [MillAbility]

      def event_handlers
        {
          Events::CreatureDied => CreatureDiedTrigger,
          Events::CardEnteredZone => CardEnteredGraveyardTrigger,
          Events::CardLeavingZone => CardLeftGraveyardTrigger,
        }
      end
    end
  end
end
