module Magic
  module Cards
    class GossipsTalent < ClassEnchantment
      card_name "Gossip's Talent"
      cost generic: 1, blue: 1
      level_costs 2 => "{1}{U}", 3 => "{3}{U}"

      # Whenever a creature you control enters, surveil 1.
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = creature? && under_your_control?

        def call
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 1))
        end
      end

      # Level 2: Whenever you attack, target attacking creature with power 3 or less can't be blocked this turn.
      class AttackTrigger < TriggeredAbility::YouAttack
        class UnblockableChoice < Magic::Choice::Targeted
          def initialize(actor:, attackers:)
            @attackers = attackers
            super(actor: actor)
          end

          def choices = @attackers.select { _1.power <= 3 }

          def choice_amount = 1

          def resolve!(target:)
            target.cant_be_blocked_this_turn!
          end
        end

        def should_perform? = actor.level >= 2 && super

        def call
          choice = UnblockableChoice.new(actor: actor, attackers: attackers)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # Level 3: Whenever a creature you control deals combat damage to a player, you may exile it, then
      # return it to the battlefield under its owner's control.
      class BlinkTrigger < TriggeredAbility
        class BlinkChoice < Magic::Choice::May
          def initialize(actor:, creature:)
            @creature = creature
            super(actor: actor)
          end

          def resolve!
            card = @creature.card
            exile_target(@creature)
            card.resolve!(controller: card.owner) if card.zone&.exile?
          end
        end

        def should_perform?
          actor.level >= 3 && event.target.is_a?(Player) && event.source.is_a?(Permanent) && event.source.controller == controller && event.source.creature?
        end

        def call
          game.choices.add(BlinkChoice.new(actor: actor, creature: event.source))
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => CreatureEntersTrigger, Events::CombatDamageDealt => BlinkTrigger).merge(AttackTrigger.handlers)
      end
    end
  end
end
