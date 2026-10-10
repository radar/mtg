module Magic
  module Cards
    NorinSwiftSurvivalist = Creature("Norin, Swift Survivalist") do
      legendary_creature_type "Human Coward"
      cost red: 1
      power 2
      toughness 1

      # "Norin can't block."
      def can_block?(_) = false
    end

    class NorinSwiftSurvivalist < Creature
      # "Whenever a creature you control becomes blocked, you may exile it. You may play that card from exile this
      # turn." Blocked once, however many creatures block it.
      class ExileChoice < Magic::Choice::May
        attr_reader :creature

        def initialize(actor:, creature:)
          super(actor: actor)
          @creature = creature
        end

        def prompt = "Exile #{creature.name}? You may play it from exile this turn."

        def resolve!
          card = creature.card
          trigger_effect(:exile, source: actor, target: creature)
          game.play_permissions.grant_until_end_of_turn(card: card, player: controller)
        end
      end

      class BlockedTrigger < TriggeredAbility
        def should_perform?
          return false unless event.attacker.controller == controller

          first = game.current_turn.events.find { _1.is_a?(Events::CreatureBlocked) && _1.attacker == event.attacker }
          first.nil? || first.equal?(event)
        end

        def call
          game.choices.add(ExileChoice.new(actor: actor, creature: event.attacker))
        end
      end

      def event_handlers = { Events::CreatureBlocked => BlockedTrigger }
    end
  end
end
