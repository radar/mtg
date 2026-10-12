module Magic
  module Cards
    TyvarThePummeler = Creature("Tyvar, the Pummeler") do
      cost generic: 1, green: 2
      legendary_creature_type "Elf Warrior"
      power 3
      toughness 3
    end

    class TyvarThePummeler < Creature
      # "Tap another untapped creature you control: Tyvar gains indestructible until end of turn. Tap it."
      class IndestructibleAbility < Magic::ActivatedAbility
        def costs
          [Costs::MultiTap.new(1) { controller.creatures.untapped.except(source) }]
        end

        def resolve!
          give_keyword(source, :indestructible)
        end
      end

      # "{3}{G}{G}: Creatures you control get +X/+X until end of turn, where X is the greatest power among creatures
      # you control."
      class PumpAbility < Magic::ActivatedAbility
        costs "{3}{G}{G}"

        def resolve!
          x = controller.creatures.map(&:power).max.to_i
          controller.creatures.each do |creature|
            pump(creature, x, x)
          end
        end
      end

      def activated_abilities = [IndestructibleAbility, PumpAbility]
    end
  end
end
