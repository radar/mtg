module Magic
  module Cards
    OldFatSpiderCantSeeMe = Saga("Old Fat Spider Can't See Me") do
      cost generic: 2, blue: 1
    end

    class OldFatSpiderCantSeeMe < Saga
      # The creatures this Saga is holding hexproof on / preventing damage from. Ability code sees the Permanent, so
      # these are read through `source.card`.
      attr_accessor :hexproof_creature, :silenced_creature

      # I -- Target creature you control gains hexproof for as long as this Saga remains on the battlefield.
      class Chapter1 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            actor.card.hexproof_creature = target
          end
        end

        def resolve!
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # II -- Prevent all damage that would be dealt by up to one target creature for as long as this Saga remains on
      # the battlefield.
      class Chapter2 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target: nil)
            actor.card.silenced_creature = target
          end
        end

        def resolve!
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # III, IV -- Draw a card.
      class Chapter3 < Saga::ChapterAbility
        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      class Chapter4 < Chapter3
      end

      def chapters = [Chapter1, Chapter2, Chapter3, Chapter4]

      class Hexproof < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HEXPROOF
        applicable_targets { [source.card.hexproof_creature].compact }
      end

      class PreventDamage < StaticAbility
        def prevents_damage_from?(origin)
          creature = @source.card.silenced_creature
          !creature.nil? && origin == creature
        end
      end

      def static_abilities = [Hexproof, PreventDamage]
    end
  end
end
