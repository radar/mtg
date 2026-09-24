module Magic
  module Cards
    BindingTheOldGods = Saga("Binding the Old Gods") do
      cost generic: 2, black: 1, green: 1
    end

    class BindingTheOldGods < Saga
      class Chapter1 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices
            battlefield.not_controlled_by(controller).nonland
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:destroy_target, target: target)
          end
        end

        def resolve!
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class Chapter2 < Saga::ChapterAbility
        def resolve!
          game.choices.add(Magic::Choice::SearchLibrary.new(actor: actor, to_zone: :battlefield, enters_tapped: true, upto: 1, filter: ->(card) { card.any_type?("Forest") }))
        end
      end

      class Chapter3 < Saga::ChapterAbility
        def resolve!
          battlefield.controlled_by(controller).creatures.each { |creature| trigger_effect(:grant_keyword, target: creature, keyword: :deathtouch) }
        end
      end

      def chapters
        [Chapter1, Chapter2, Chapter3]
      end
    end
  end
end
