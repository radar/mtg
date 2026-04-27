module Magic
  module Cards
    AgathasSoulCauldron = Artifact("Agatha's Soul Cauldron") do
      cost generic: 2
    end

    class AgathasSoulCauldron < Artifact
      class CounterChoice < Magic::Choice::Targeted
        def choices
          game.creatures.controlled_by(actor.controller)
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          trigger_effect(:add_counter, target: target, counter_type: Counters::Plus1Plus1)
        end
      end

      class ExileAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices
          game.graveyard_cards
        end

        def resolve!(target:)
          trigger_effect(:exile, target: target)
          source.exiled_cards << target

          if target.types.include?(T::Creature)
            game.choices.add(CounterChoice.new(actor: source))
          end
        end
      end

      class AnyColorForCreatureActivations < Abilities::Static::AnyColorForCreatureActivations
      end

      class GrantAbilitiesFromExile < Abilities::Static::GrantActivatedAbilities
        def applies_to?(permanent)
          permanent.types.include?(T::Creature) &&
            permanent.controller == controller &&
            permanent.counters.any? { |c| c.is_a?(Counters::Plus1Plus1) }
        end

        def granted_abilities
          @source.exiled_cards.creatures.flat_map(&:activated_abilities)
        end
      end

      def activated_abilities = [ExileAbility]
      def static_abilities = [AnyColorForCreatureActivations, GrantAbilitiesFromExile]
    end
  end
end
