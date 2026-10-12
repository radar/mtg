module Magic
  module Cards
    class InnkeepersTalent < ClassEnchantment
      card_name "Innkeeper's Talent"
      cost generic: 1, green: 1
      level_costs 2 => "{G}", 3 => "{3}{G}"

      # At the beginning of combat on your turn, put a +1/+1 counter on target creature you control.
      class CombatTrigger < TriggeredAbility
        class CounterChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            add_counter("+1/+1", to: target)
          end
        end

        def should_perform? = controllers_turn?

        def call
          choice = CounterChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # Level 2: Permanents you control with counters on them have ward {1}.
      class CounterWard < TriggeredAbility::GrantedWard
        def should_perform? = actor.level >= 2 && super

        def warded?(permanent) = permanent.counters.any?
      end

      def event_handlers
        super.merge(Events::BeginningOfCombat => CombatTrigger).merge(CounterWard.handlers)
      end

      # Level 3: If you would put one or more counters on a permanent or player, put twice that many of
      # each of those kinds of counters on that permanent or player instead.
      class CounterDoubler < ReplacementEffect::CountersYouPutDoubler
        def applies?(effect) = receiver.level >= 3 && super
      end

      def replacement_effects = CounterDoubler.registrations
    end
  end
end
