module Magic
  module Cards
    ChargeThrough = Instant("Charge Through") do
      cost green: 1
    end

    class ChargeThrough < Instant
      def single_target?
        true
      end

      def target_choices
        creatures
      end

      def resolve!(target:)
        if target.zone == battlefield
          target.grant_keyword(Keywords::TRAMPLE, until_eot: true)
          controller.draw!
        end
      end
    end
  end
end
