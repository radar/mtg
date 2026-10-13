module Magic
  module Cards
    EssenceChanneler = Creature("Essence Channeler") do
      cost generic: 1, white: 1
      creature_type("Bat Cleric")
      power 2
      toughness 1
    end

    class EssenceChanneler < Creature
      # As long as you've lost life this turn, this creature has flying and vigilance.
      class LostLifeKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING, Keywords::VIGILANCE

        def applicable_targets
          game.current_turn.life_lost_by_player(controller).positive? ? [source] : []
        end
      end

      def static_abilities = [LostLifeKeywords]

      # Whenever you gain life, put a +1/+1 counter on this creature.
      class LifeGainTrigger < TriggeredAbility
        def should_perform? = event.player == controller

        def call
          add_counter("+1/+1")
        end
      end

      # When this creature dies, put its counters on target creature you control.
      class DiesTrigger < TriggeredAbility::Death
        class MoveCounters < Magic::Choice::Targeted
          def initialize(actor:, counters:)
            @counters = counters
            super(actor: actor)
          end

          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            @counters.group_by(&:class).each do |counter_class, counters|
              add_counter counter_class, to: target, amount: counters.size
            end
          end
        end

        def call
          counters = actor.counters.to_a
          return if counters.empty?

          choice = MoveCounters.new(actor: actor, counters: counters)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def death_triggers = [DiesTrigger]

      def event_handlers = super.merge(Events::LifeGain => LifeGainTrigger)
    end
  end
end
