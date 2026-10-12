module Magic
  module Cards
    RustShieldRampager = Creature("Rust-Shield Rampager") do
      cost generic: 3, green: 1
      creature_type("Raccoon Warrior")
      power 4
      toughness 4
      offspring generic: 2
    end

    class RustShieldRampager < Creature
      # This creature can't be blocked by creatures with power 2 or less.
      def can_be_blocked?(blocker) = blocker.power > 2
    end
  end
end
