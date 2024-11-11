module Magic
  module Cards
    class BattleForBretagard < Saga
      card_name "Battle for Bretagard"
      cost generic: 1, green: 1, white: 1

      HumanWarriorToken = Token.create "Human Warrior" do
        creature_type "Human Warrior"
        power 1
        toughness 1
        colors :white
      end

      ElfWarriorToken = Token.create "Elf Warrior" do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      class Chapter1 < Chapter
        def resolve
          actor.trigger_effect(:create_token, token_class: HumanWarriorToken)
        end
      end

      class Chapter2 < Chapter
        def resolve
          actor.trigger_effect(:create_token, token_class: ElfWarriorToken)
        end
      end

      class Chapter3 < Chapter
        def resolve
          actor.game.add_choice(BattleForBretagard::Choice.new(actor: actor))
        end
      end

      class Choice < Magic::Choice
        def choices
          you_control = battlefield.controlled_by(controller)

          Magic::Targets::Choices.new(
            choices: you_control.artifact.tokens + you_control.creature.tokens,
            amount: 0..
          )
        end

        def resolve!(targets:)
          targets.each(&:copy!)
        end
      end

      def chapters
        [Chapter1, Chapter2, Chapter3]
      end
    end
  end
end
