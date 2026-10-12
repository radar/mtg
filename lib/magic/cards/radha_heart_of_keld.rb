module Magic
  module Cards
    RadhaHeartOfKeld = Creature("Radha, Heart of Keld") do
      legendary_creature_type "Elf Warrior"
      cost "{2}{R}{G}"
      power 3
      toughness 3
    end

    class RadhaHeartOfKeld < Creature
      class FirstStrikeGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE

        def applicable_targets
          if game.current_turn.active_player == controller
            [source]
          else
            []
          end
        end
      end

      class PumpAbility < Magic::ActivatedAbility
        costs "{4}{R}{G}"

        def resolve!
          x = controller.lands.count
          pump(source, x, x)
        end
      end

      class TopLibraryPermission < StaticAbility
        def permits_casting_from_top?(card)
          card == controller.library.first && card.land?
        end
      end

      def static_abilities = [FirstStrikeGrant, TopLibraryPermission]
      def activated_abilities = [PumpAbility]
    end
  end
end
