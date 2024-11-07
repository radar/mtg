module Magic
  module Cards
    class Pridemalkin < Creature
      card_name "Pridemalkin"
      cost "{2}{G}"
      type "Creature -- Cat"
      power 2
      toughness 1

      class Choice < Magic::Choice
        def choices
          Magic::Targets::Choices.new(
            choices: game.battlefield.by_any_type(T::Creature).controlled_by(owner),
            amount: 1
          )
        end

        def resolve!(target:)
          actor.trigger_effect(
            :add_counter,
            source: actor,
            target: target,
            counter_type: Counters::Plus1Plus1
          )
        end
      end

      enters_the_battlefield do
        game.choices.add(Choice.new(actor: actor))
      end

      class TrampleAddition < Abilities::Static::KeywordGrant
        keyword_grants Keywords::TRAMPLE

        def applies_to?(permanent)
          permanent.counters.of_type(Magic::Counters::Plus1Plus1).any?
        end

        def applicable_targets
          source.controller.creatures
        end
      end

      def static_abilities = [TrampleAddition]
    end
  end
end
