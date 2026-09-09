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
        trigger_effect(:create_token, token_class: ForestDryadToken, amount: value_for_x)
      end
    end
  end
end