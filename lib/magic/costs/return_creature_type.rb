module Magic
  module Costs
    # "Return an Elf you control to its owner's hand": `ReturnCreatureType.new(source, "Elf")`. The payer names
    # one creature of that type the controller controls (`pay_return_creature(elf)`). It may be the source itself
    # when the source has the type.
    class ReturnCreatureType
      attr_reader :permanent, :type

      def initialize(permanent, type)
        @permanent = permanent
        @type = type
      end

      def choices = permanent.controller.creatures.by_type(type)

      def can_pay?(_player = nil) = choices.any?

      def pay(payment:)
        raise "Return one of: #{choices.map(&:name).join(', ')}" unless choices.include?(payment)

        payment.return_to_hand
      end

      def finalize!(_player)
      end
    end
  end
end
