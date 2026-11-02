module Magic
  module Cards
    RushTheRoom = Instant("Rush the Room") do
      cost red: 1
    end

    class RushTheRoom < Instant
      def single_target? = true

      def target_choices = battlefield.creatures

      # "Target creature gets +1/+0 and gains first strike until end of turn. If it's a Goblin or Orc, it also gains haste
      # until end of turn."
      def resolve!(target:)
        pump target, 1, 0
        give_keyword target, :first_strike
        give_keyword target, :haste if target.type?("Goblin") || target.type?("Orc")
        super()
      end
    end
  end
end
