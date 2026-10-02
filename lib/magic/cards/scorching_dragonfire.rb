module Magic
  module Cards
    ScorchingDragonfire = Instant("Scorching Dragonfire") do
      cost generic: 1, red: 1
    end

    class ScorchingDragonfire < Instant
      def target_choices
        battlefield.creatures + battlefield.planeswalkers
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 3)
        target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
      end
    end
  end
end
