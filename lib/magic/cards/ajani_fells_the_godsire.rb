module Magic
  module Cards
    AjaniFellsTheGodsire = Saga("Ajani Fells the Godsire") do
      cost generic: 3, white: 2
    end

    class AjaniFellsTheGodsire < Saga
      CatWarriorToken = Token.create("Cat Warrior") do
        creature_type "Cat Warrior"
        power 2
        toughness 1
        colors :white
      end

      # I -- Exile target creature an opponent controls with power 3 or greater.
      class Chapter1 < Saga::ChapterAbility
        class ExileChoice < Magic::Choice::Targeted
          def prompt = "Exile target creature an opponent controls with power 3 or greater."

          def choices = battlefield.not_controlled_by(controller).creatures.select { _1.power >= 3 }

          def choice_amount = 1

          def resolve!(target:)
            exile_target(target)
          end
        end

        def resolve!
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # II -- Create a 2/1 white Cat Warrior creature token, then put a vigilance counter on a creature you control.
      class Chapter2 < Saga::ChapterAbility
        class CounterChoice < Magic::Choice::Targeted
          def prompt = "Put a vigilance counter on a creature you control."

          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            add_counter Counters::Vigilance, to: target
          end
        end

        def resolve!
          create_token(token: CatWarriorToken)
          game.add_choice(CounterChoice.new(actor: actor))
        end
      end

      # III -- Target creature you control gains double strike until end of turn.
      class Chapter3 < Saga::ChapterAbility
        class DoubleStrikeChoice < Magic::Choice::Targeted
          def prompt = "Target creature you control gains double strike until end of turn."

          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            give_keyword(target, :double_strike)
          end
        end

        def resolve!
          choice = DoubleStrikeChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def chapters = [Chapter1, Chapter2, Chapter3]
    end
  end
end
