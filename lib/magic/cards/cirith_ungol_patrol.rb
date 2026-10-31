module Magic
  module Cards
    CirithUngolPatrol = Creature("Cirith Ungol Patrol") do
      cost generic: 4, black: 1
      creature_type "Orc Soldier"
      power 4
      toughness 5
    end

    class CirithUngolPatrol < Creature
      # "{1}, {T}, Sacrifice another creature: Draw a card, then create a Food token."
      class SacrificeAbility < Magic::ActivatedAbility
        costs "{1}, {T}, Sacrifice another creature"

        def resolve!
          draw_card
          create_token(token: Tokens::Food)
        end
      end

      def activated_abilities = [SacrificeAbility]
    end
  end
end
