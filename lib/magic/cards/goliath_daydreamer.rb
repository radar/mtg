module Magic
  module Cards
    GoliathDaydreamer = Creature("Goliath Daydreamer") do
      cost generic: 2, red: 2
      creature_type "Giant Wizard"
      power 4
      toughness 4
    end

    class GoliathDaydreamer < Creature
      # "Whenever you cast an instant or sorcery spell from your hand, exile that card with
      # a dream counter on it instead of putting it into your graveyard as it resolves."
      # The trigger resolves before the spell does, and marks the card; Actions::Cast#resolve!
      # then exiles it (with the counter) rather than moving it to the graveyard.
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player == controller && (spell.instant? || spell.sorcery?) && spell.zone&.hand?
        end

        def call
          spell.exile_with_dream_counter = true
        end
      end

      # "Whenever this creature attacks, you may cast a spell from among cards you own in
      # exile with dream counters on them without paying its mana cost."
      class CastChoice < Magic::Choice::May
        def choices
          game.exile.select { |card| card.dream_counter && card.owner == controller }
        end

        def target_choices
          Magic::Targets::Choices.new(choices:, amount: 1)
        end

        def single_target?
          true
        end

        # `targets`: the targets the free spell needs, if any.
        def resolve!(target:, targets: [])
          raise ArgumentError, "#{target.name} isn't exiled with a dream counter" unless choices.include?(target)

          controller.cast(card: target, by_effect: true) do |action|
            action.mana_cost = 0
            action.targeting(*targets) if targets.any?
          end
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacker == actor
        end

        def call
          choice = CastChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def event_handlers
        {
          Events::SpellCast => SpellCastTrigger,
          Events::CreatureAttacked => AttacksTrigger
        }
      end
    end
  end
end
