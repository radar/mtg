module Magic
  module Permanents
    module Modifications
      def add_types(*types)
        modifiers << Magic::Permanents::Modifications::AdditionalType.new(
          types: types,
        )
      end

      def modify_base_power(power)
        modifiers << Magic::Permanents::Modifications::BasePower.new(
          base_power: power,
        )
      end

      def modify_power(power)
        modifiers << Magic::Permanents::Modifications::Power.new(
          power: power,
        )
      end

      def modify_base_toughness(toughness)
        modifiers << Magic::Permanents::Modifications::BaseToughness.new(
          base_toughness: toughness,
        )
      end

      def modify_toughness(toughness)
        modifiers << Magic::Permanents::Modifications::Toughness.new(
          toughness: toughness,
        )
      end
    end
  end
end
