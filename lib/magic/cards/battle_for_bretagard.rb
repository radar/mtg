module Magic
  module Cards
    BattleForBretagard = Saga("Battle for Bretagard") do
      cost generic: 1, white: 1, green: 1
    end

    class BattleForBretagard < Saga
      class Chapter1 < Saga::ChapterAbility
        HumanWarriorToken = Token.create "Human Warrior" do
          creature_type "Human Warrior"
          power 1
          toughness 1
          colors :white
        end

        def resolve!
          actor.trigger_effect(:create_token, token_class: HumanWarriorToken)
        end
      end

      class Chapter2 < Saga::ChapterAbility
        ElfWarriorToken = Token.create "Elf Warrior" do
          creature_type "Elf Warrior"
          power 1
          toughness 1
          colors :green
        end

        def resolve!
          actor.trigger_effect(:create_token, token_class: ElfWarriorToken)
        end
      end

      class Chapter3 < Saga::ChapterAbility
        def resolve!
          actor.controller.creatures.each do |creature|
            actor.trigger_effect(:grant_keyword, keyword: :deathtouch, target: creature)
          end
        end
      end

      def chapters
        [Chapter1, Chapter2, Chapter3]
      end
    end
  end
end
