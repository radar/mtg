module Magic
  module Cards
    SelflessSpirit = Creature("Selfless Spirit") do
      cost generic: 1, white: 1
      creature_type "Spirit Cleric"
      keywords :flying
      power 2
      toughness 1
    end

    class SelflessSpirit < Creature
      # "Sacrifice this creature: Creatures you control gain indestructible until end of turn."
      class SacrificeAbility < Magic::ActivatedAbility
        costs "Sacrifice {this}"

        def resolve!
          controller.creatures.each(&:grant_indestructible!)
        end
      end

      def activated_abilities = [SacrificeAbility]
    end
  end
end
