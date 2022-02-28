module Magic
  module Cards
    class PathOfPeace < Sorcery
      NAME = "Path of Peace"
      COST = { generic: 3, white: 1 }


      def resolve!
        add_effect(
          "DestroyControllerGainsLife",
          choices: battlefield.cards.select(&:creature?),
        )
        super
      end
    end
  end
end
