module Magic
  module Permanents
    module Modifications
      # "Target creature's power and toughness are switched until end of turn."
      # Layer 7d: applied after 7c (modify). Multiple switches commute -- only
      # parity matters -- so ContinuousEffects just counts these, it doesn't need
      # to fold them in timestamp order.
      class SwitchPowerToughness < ContinuousEffect
        layer 7, sublayer: :d
      end
    end
  end
end
