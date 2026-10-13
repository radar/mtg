module Magic
  module Cards
    BarbflareGremlin = Creature("Barbflare Gremlin") do
      cost generic: 3, red: 1
      creature_type "Gremlin"
      keywords :first_strike, :haste
      power 3
      toughness 2
    end

    class BarbflareGremlin < Creature
      # "Whenever a player taps a land for mana, if this creature is tapped, that player adds one mana of any type that land
      # produced. Then that land deals 1 damage to that player." Like Lavaleaper, this rides on the land's mana ability.
      class LandManaDoubling < StaticAbility
        def additional_mana(land, mana)
          return unless land.land? && @source.tapped?

          land.controller.add_mana(**mana)
          land.deal_damage 1, to: land.controller
        end
      end

      def static_abilities = [LandManaDoubling]
    end
  end
end
