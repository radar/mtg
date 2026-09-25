module Magic
  module Permanents
    module Modifications
      def add_types(*types)
        modifiers << AdditionalType.new(
          types: types,
        )
      end

      # "~ becomes a 4/4 artifact creature until end of turn." (a manland, Firdoch Core)
      def become_creature!(power:, toughness:, types: [], until_eot: true)
        modifiers << AdditionalType.new(types: [T::Creature, *types], until_eot:)
        modifiers << BasePower.new(base_power: power, until_eot:)
        modifiers << BaseToughness.new(base_toughness: toughness, until_eot:)
        apply_continuous_effects!
      end

      def modify_base_power(power)
        modifiers << BasePower.new(
          base_power: power,
        )
      end

      def modify_power(power)
        modifiers << Power.new(
          power_modification: power,
        )
      end

      def modify_base_toughness(toughness)
        modifiers << BaseToughness.new(
          base_toughness: toughness,
        )
      end

      def modify_toughness(toughness)
        modifiers << Toughness.new(
          toughness_modification: toughness,
        )
      end

      # "~ becomes red until end of turn" / "becomes all colors": replaces its colors.
      def change_colors!(colors, until_eot: true)
        modifiers << Color.new(colors: colors, until_eot: until_eot)
      end

      def grant_keyword(keyword, until_eot: true)
        modifiers << KeywordGrant.new(keyword_grant: keyword, until_eot: until_eot)
      end

      def prevent_blocking!(until_eot: true)
        modifiers << CannotBlock.new(until_eot: until_eot)
      end

      def prevented_from_blocking?
        modifiers.any? { |modifier| modifier.is_a?(CannotBlock) }
      end

      def method_missing(method_name, **kwargs)
        match = method_name.to_s.match(/\Agrant_(\w+)!\z/)
        if match && Cards::Keywords.const_defined?(match[1].upcase)
          grant_keyword(Cards::Keywords.const_get(match[1].upcase), **kwargs)
        else
          super
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        match = method_name.to_s.match(/\Agrant_(\w+)!\z/)
        (match && Cards::Keywords.const_defined?(match[1].upcase)) || super
      end

      def remove_keyword_grant(grant)
        @keyword_grants.delete(grant)
      end
    end
  end
end
