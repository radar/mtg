module Magic
  module Cards
    CagedZombie = Creature("Caged Zombie") do
      cost generic: 2, black: 1
      creature_type "Zombie"
      power 2
      toughness 3
    end

    class CagedZombie < Creature
      # "{1}{B}, {T}: Each opponent loses 2 life. Activate only if a creature died this turn."
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{B}, {T}"

        def requirements_met?
          game.current_turn.events.any? { |event| event.is_a?(Events::CreatureDied) }
        end

        def resolve!
          game.opponents(controller).each { |opponent| trigger_effect(:lose_life, target: opponent, life: 2) }
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
