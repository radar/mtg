module Magic
  module Costs
    # "Sacrifice another creature": any creature the controller controls except the source.
    class SacrificeAnother < Sacrifice
      class SourceSacrificed < StandardError; end

      def pay(payment:)
        raise SourceSacrificed, "#{permanent.name} can't sacrifice itself to pay for its own cost" if payment == permanent

        super
      end
    end
  end
end
