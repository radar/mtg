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
        return false unless target.respond_to?(:protected_from?)

        origin = source.respond_to?(:colors) ? source : (source.source if source.respond_to?(:source))
        !origin.nil? && target.protected_from?(origin)
      end
    end
  end
end
