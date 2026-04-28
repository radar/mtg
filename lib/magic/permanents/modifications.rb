module Magic
  module Permanents
    module Modifications
      def add_types(*types)
        modifiers << AdditionalType.new(
          types: types,
        )
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

      def grant_keyword(keyword, until_eot: true)
        modifiers << KeywordGrant.new(keyword_grant: keyword, until_eot: until_eot)
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
