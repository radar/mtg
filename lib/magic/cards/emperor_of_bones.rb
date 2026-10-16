module Magic
  module Cards
    EmperorOfBones = Creature("Emperor of Bones") do
      cost generic: 1, black: 1
      creature_type "Skeleton Noble"
      power 2
      toughness 2
    end

    class EmperorOfBones < Creature
      # "{1}{B}: Adapt 2." (If it has no +1/+1 counters on it, put two +1/+1 counters on it.)
      class AdaptAbility < Magic::ActivatedAbility
        costs "{1}{B}"

        def resolve!
          return if source.counters.of_type(Counters::Plus1Plus1).any?

          add_counter("+1/+1", to: source, amount: 2)
        end
      end

      class ExileChoice < Magic::Choice::Targeted
        def choices = game.players.flat_map { |player| player.graveyard.cards.to_a }

        def choice_amount = 0..1

        def resolve!(target:)
          raise ArgumentError, "#{Array(target).first&.name} is not a valid choice" unless target.is_a?(Magic::Card) && choices.include?(target)

          actor.exile_with_this!(target)
        end
      end

      # "At the beginning of combat on your turn, exile up to one target card from a graveyard."
      class CombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          choice = ExileChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class ReturnChoice < Magic::Choice::Targeted
        def choices = actor.exiled_cards.select { _1.zone&.exile? && _1.creature? }

        def choice_amount = 1

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

          creature = Permanent.put_onto_battlefield(game: game, card: target, from_zone: target.zone, controller: controller, counters: { "finality" => 1 })
          # It is a new object now (CR 400.7), so it is no longer "exiled with" this creature.
          actor.remove_from_exile(target)
          creature.grant_haste!(until_eot: false)
          creature.register_turn_trigger(Events::BeginningOfEndStep, Blitz::EndStepSacrificeTrigger)
        end
      end

      # "Whenever one or more +1/+1 counters are put on this creature, put a creature card exiled with this creature onto
      # the battlefield under your control with a finality counter on it. It gains haste. Sacrifice it at the beginning of
      # the next end step."
      class CountersTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor && Counters[event.counter_type] == Counters::Plus1Plus1
        end

        def call
          choice = ReturnChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def activated_abilities = [AdaptAbility]

      def event_handlers
        { Events::BeginningOfCombat => CombatTrigger, Events::CounterAddedToPermanent => CountersTrigger }
      end
    end
  end
end
