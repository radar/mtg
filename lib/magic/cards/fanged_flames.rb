module Magic
  module Cards
    FangedFlames = Sorcery("Fanged Flames") do
      cost generic: 1, red: 1
      keywords :devoid
    end

    class FangedFlames < Sorcery
      def target_choices = [*battlefield.creatures, *battlefield.planeswalkers]

      # "...deals 4 damage to target creature or planeswalker. If that creature or planeswalker would die this turn,
      # exile it instead."
      def resolve!(target:)
        deal_damage(4, to: target)
        target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
      end
    end
  end
end
