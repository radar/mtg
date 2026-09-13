module Magic
  module Cards
    GibberingFiend = Creature("Gibbering Fiend") do
      power 2
      toughness 1
      cost generic: 1, red: 1
      creature_type "Devil"
    end

    class GibberingFiend < Creature
      TYPE_PREDICATES = %i[creature? artifact? enchantment? instant? sorcery? land? planeswalker?].freeze

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponents.each { |opponent| actor.trigger_effect(:deal_damage, damage: 1, target: opponent) }
        end
      end

      class DeliriumUpkeepTrigger < TriggeredAbility
        def should_perform?
          opponent? && delirium?
        end

        def call
          actor.trigger_effect(:deal_damage, damage: 1, target: event.player)
        end

        private

        def delirium?
          types = controller.graveyard.cards.flat_map do |card|
            TYPE_PREDICATES.select { |predicate| card.public_send(predicate) }
          end
          types.uniq.size >= 4
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        { Events::BeginningOfUpkeep => DeliriumUpkeepTrigger }
      end
    end
  end
end
