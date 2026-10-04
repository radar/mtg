module Magic
  module Cards
    ZulAshurLichLord = Creature("Zul Ashur, Lich Lord") do
      cost generic: 1, black: 1
      legendary_creature_type("Zombie Warlock")
      ward life: 2
      power 2
      toughness 2
    end

    class ZulAshurLichLord < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices
          controller.graveyard.cards.select { _1.type?("Zombie") && _1.type?("Creature") }
        end

        def resolve!(target:)
          game.play_permissions.grant_until_end_of_turn(card: target, player: controller, from_graveyard: true)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
