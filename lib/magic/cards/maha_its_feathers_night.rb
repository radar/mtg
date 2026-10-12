module Magic
  module Cards
    MahaItsFeathersNight = Creature("Maha, Its Feathers Night") do
      legendary_creature_type "Elemental Bird"
      cost generic: 3, black: 2
      keywords :flying, :trample
      power 6
      toughness 5
      ward discard: true
    end

    class MahaItsFeathersNight < Creature
      # Creatures your opponents control have base toughness 1.
      class OpposingToughness < Abilities::Static::CharacteristicSetting
        def applicable_targets = battlefield.not_controlled_by(source.controller).creatures

        def set_base_toughness = 1
      end

      def static_abilities = [OpposingToughness]
    end
  end
end
