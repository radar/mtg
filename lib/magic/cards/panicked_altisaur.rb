module Magic
  module Cards
    PanickedAltisaur = Creature("Panicked Altisaur") do
      cost "{4}{R}"
      creature_type "Dinosaur"
      power 4
      toughness 5
      keywords :reach
    end

    class PanickedAltisaur < Creature
      class PingAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          game.opponents(controller).each { |opponent| trigger_effect(:deal_damage, damage: 2, target: opponent) }
        end
      end

      def activated_abilities = [PingAbility]
    end
  end
end
