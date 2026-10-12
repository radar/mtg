module Magic
  module Cards
    IntrudingSoulrager = Creature("Intruding Soulrager") do
      cost blue: 1, red: 1
      creature_type "Spirit"
      keywords :vigilance
      power 2
      toughness 2
    end

    class IntrudingSoulrager < Creature
      # "{T}, Sacrifice a Room: This creature deals 2 damage to each opponent. Draw a card."
      class SacrificeRoomAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice a Room"

        def resolve!(sacrificed:)
          game.opponents(controller).each { deal_damage(2, to: _1) }
          trigger_effect(:draw_card)
        end
      end

      def activated_abilities = [SacrificeRoomAbility]
    end
  end
end
