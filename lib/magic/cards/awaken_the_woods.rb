module Magic
  module Cards
    class AwakenTheWoods < Sorcery
      card_name "Awaken the Woods"
      cost x: 1, green: 2

      ForestDryadToken = Token.create("Forest Dryad") do
        type T::Land, T::Creature, T::Lands::Forest, T::Creatures["Dryad"]
        power 1
        toughness 1
        colors :green
      end

      def resolve!(value_for_x:)
        create_token(token:ForestDryadToken, amount: value_for_x)
      end
    end
  end
end