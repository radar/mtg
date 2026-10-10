module Magic
  module Cards
    JumpScare = Instant("Jump Scare") do
      cost white: 1
    end

    class JumpScare < Instant
      def target_choices
        battlefield.creatures
      end

      def single_target?
        true
      end

      def resolve!(target:)
        target.modify_power(2)
        target.modify_toughness(2)
        target.grant_keyword(Keywords::FLYING)
        target.add_types(T::Enchantment, T::Creatures["Horror"])
      end
    end
  end
end
