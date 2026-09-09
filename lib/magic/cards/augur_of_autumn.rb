module Magic
  module Cards
    AugurOfAutumn = Creature("Augur of Autumn") do
      cost generic: 1, green: 2
      creature_type "Human Druid"
      power 3
      toughness 3
    end

    class AugurOfAutumn < Creature
      def additional_lands_per_turn = 1
    end
  end
end