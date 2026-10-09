module Magic
  module Effects
    class TargetedEffect < Effect
      class InvalidTarget < StandardError; end;

      attr_reader :source, :target

      def initialize(source:, target:)
        @source = source
        @target = target
      end

      # Protection: damage from a source the target is protected from is prevented.
      def damage_prevented?
        return true if target.respond_to?(:prevents_damage?) && target.prevents_damage?
        return true if damage_prevented_by_static_ability?
        return false unless target.respond_to?(:protected_from?)

        origin = source.respond_to?(:colors) ? source : (source.source if source.respond_to?(:source))
        !origin.nil? && target.protected_from?(origin)
      end

      # A battlefield static ability may answer `prevents_damage_from?(source)` ("Prevent all damage that would be
      # dealt by that creature for as long as this Saga remains on the battlefield").
      def damage_prevented_by_static_ability?
        origin = source.respond_to?(:colors) ? source : (source.source if source.respond_to?(:source))
        return false if origin.nil? || !respond_to?(:game) || game.nil?

        game.battlefield.static_abilities.any? { _1.respond_to?(:prevents_damage_from?) && _1.prevents_damage_from?(origin) }
      end
    end
  end
end
