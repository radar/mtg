module Magic
  module Cards
    class TearAsunder < Instant
      card_name "Tear Asunder"
      cost generic: 1, green: 1
      kicker_cost generic: 1, black: 1

      def target_choices
        if kicker_cost.paid?
          battlefield.nonland
        else
          battlefield.permanents.by_any_type(T::Artifact, T::Enchantment)
        end
      end

      def resolve!(target:)
        trigger_effect(:exile, target: target)
      end
    end
  end
end