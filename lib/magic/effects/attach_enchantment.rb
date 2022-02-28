module Magic
  module Effects
    class AttachEnchantment < TargetedEffect
      def requires_choices?
        true
      end

      def resolve(target)
        source.attach!(target)
      end
    end
  end
end
