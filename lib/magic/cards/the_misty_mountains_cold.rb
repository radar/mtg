module Magic
  module Cards
    TheMistyMountainsCold = Saga("The Misty Mountains Cold") do
      cost generic: 2, red: 1
    end

    class TheMistyMountainsCold < Saga
      DragonToken = Token.create "Dragon" do
        creature_type "Dragon"
        power 6
        toughness 6
        colors :red
        keywords :flying
      end

      # "Create a Treasure token. Then if you control four or more Treasures, sacrifice this Saga. If you do, create a
      # 6/6 red Dragon creature token with flying."
      class TreasureChapter < Saga::ChapterAbility
        def resolve!
          trigger_effect(:create_token, token_class: Tokens::Treasure, controller: controller)
          return unless controller.permanents.count { _1.type?("Treasure") } >= 4

          actor.sacrifice!
          trigger_effect(:create_token, token_class: DragonToken, controller: controller)
        end
      end

      class Chapter1 < TreasureChapter; end
      class Chapter2 < TreasureChapter; end
      class Chapter3 < TreasureChapter; end
      class Chapter4 < TreasureChapter; end

      def chapters = [Chapter1, Chapter2, Chapter3, Chapter4]
    end
  end
end
