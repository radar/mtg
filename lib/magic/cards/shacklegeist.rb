module Magic
  module Cards
    Shacklegeist = Creature("Shacklegeist") do
      creature_type "Spirit"
      power 2
      toughness 2
      keywords :flying

      def can_block?(permanent)
        permanent.flying?
      end
    end

    class Shacklegeist < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        def costs = [Costs::MultiTap.new(-> (c) { c.type?("Spirit") }, 2)]

        def target_choices
          game.battlefield.not_controlled_by(controller).creatures
        end

        def resolve!(target:)
          trigger_effect(:tap, target: target)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
