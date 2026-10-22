module Magic
  module Cards
    UlamogTheDefiler = Creature("Ulamog, the Defiler") do
      cost generic: 10
      legendary_creature_type "Eldrazi"
      ward sacrifice_any: 2
      power 7
      toughness 7
    end

    class UlamogTheDefiler < Creature
      # "When you cast this spell, target opponent exiles the top half of their library, rounded up."
      class OpponentChoice < Magic::Choice::Targeted
        def choices = game.opponents(controller)

        def choice_amount = 1

        def resolve!(target:)
          cards = target.library.cards.first((target.library.cards.size + 1) / 2)
          cards.each { |card| exile_target(card) }
        end
      end

      class CastTrigger < TriggeredAbility::CastThisSpell
        def call
          game.add_choice(OpponentChoice.new(actor: actor))
        end
      end

      # "Ulamog enters with a number of +1/+1 counters on it equal to the greatest mana value among cards in exile."
      def entering_counters
        greatest = game.exile.cards.map(&:mana_value).max.to_i
        greatest.positive? ? { "+1/+1" => greatest } : {}
      end

      # "Ulamog has annihilator X, where X is the number of +1/+1 counters on it."
      # A separately granted instance of annihilator still triggers on its own (702.86b), hence `+ super`.
      class CounterAnnihilator < TriggeredAbility::Annihilator
        def instance_amounts = [actor.counters.of_type(Counters::Plus1Plus1).count] + super
      end

      def cast_triggers = [CastTrigger]
      def event_handlers = super.merge(Events::CreatureAttacked => CounterAnnihilator)
    end
  end
end
