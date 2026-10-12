module Magic
  module Cards
    TheGreatGoblin = Creature("The Great Goblin") do
      cost "{1}{B/R}{B/R}"
      legendary_creature_type "Goblin Noble"
      power 3
      toughness 2
    end

    class TheGreatGoblin < Creature
      TYPES = %w[Goblin Orc Army].freeze

      # "Whenever you put one or more counters on a Goblin, Orc, or Army you control, The Great Goblin deals 2 damage to
      # target opponent."
      class CounterTrigger < TriggeredAbility
        def should_perform?
          target = event.target
          target.is_a?(Magic::Permanent) && target.controller == controller && TYPES.any? { target.type?(_1) } &&
            (event.source.nil? || event.source.controller == controller)
        end

        def call
          opponents.each { |opponent| trigger_effect(:deal_damage, target: opponent, damage: 2) }
        end
      end

      # "Whenever another Goblin, Orc, or Army you control dies, exile the top card of your library. You may play it
      # until the end of your next turn."
      class DiesTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor && event.controller == controller && TYPES.any? { event.permanent.type?(_1) }
        end

        def call
          card = controller.library.first
          return unless card

          trigger_effect(:exile, target: card)
          game.play_permissions.grant_until_end_of_next_turn(card: card, player: controller)
        end
      end

      def event_handlers
        super.merge({ Events::CounterAddedToPermanent => CounterTrigger, Events::CreatureDied => DiesTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
