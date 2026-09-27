module Magic
  module Cards
    SpiralIntoSolitude = Aura("Spiral into Solitude") do
      cost generic: 1, white: 1
    end

    class SpiralIntoSolitude < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      def can_attack?
        false
      end

      def can_block?(_)
        false
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}{W}, Blight 1, Sacrifice {this}"

        def resolve!
          trigger_effect(:exile, target: source.attached_to)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
