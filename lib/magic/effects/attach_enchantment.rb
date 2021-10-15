module Magic
  module Effects
    class AttachEnchantment < Effect
      attr_reader :enchantment

      def initialize(enchantment:, **args)
        @enchantment = enchantment
        super(**args)
      end

      def requires_choices?
        true
      end

      def multiple_targets?
        false
      end

      def resolve(target:)
        target.attachments << enchantment
      end
    end
  end
end
