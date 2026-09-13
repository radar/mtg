module Magic
  module Abilities
    module Static
      class AdditionalCountersForEntering < StaticAbility
        attr_reader :source

        def additional_counters_for_entering(_permanent)
          0
        end
      end
    end
  end
end
