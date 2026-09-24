module Magic
  module Cards
    TheEldestReborn = Saga("The Eldest Reborn") do
      cost generic: 4, black: 1
    end

    class TheEldestReborn < Saga
      class Chapter1 < Saga::ChapterAbility
        class SacrificeChoice < Magic::Choice::Targeted
          def initialize(actor:, player:)
            @player = player
            super(actor: actor)
          end

          def choices
            battlefield.controlled_by(@player).by_any_type("Creature", "Planeswalker")
          end

          def choice_amount = 1

          def resolve!(target:)
            target.sacrifice!
          end
        end

        def resolve!
          game.opponents(controller).each do |opponent|
            choice = SacrificeChoice.new(actor: actor, player: opponent)
            game.choices.add(choice) if choice.choices.any?
          end
        end
      end

      class Chapter2 < Saga::ChapterAbility
        def resolve!
          game.opponents(controller).each { |opponent| game.add_choice(Magic::Choice::Discard.new(player: opponent)) }
        end
      end

      class Chapter3 < Saga::ChapterAbility
        class TargetChoice < Magic::Choice::Targeted
          def choices
            game.graveyard_cards.by_any_type("Creature", "Planeswalker")
          end

          def choice_amount = 1

          def resolve!(target:)
            trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: controller)
          end
        end

        def resolve!
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def chapters
        [Chapter1, Chapter2, Chapter3]
      end
    end
  end
end
