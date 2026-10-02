module Magic
  module Cards
    ObliteratingBolt = Sorcery("Obliterating Bolt") do
      cost generic: 1, red: 1
    end

    class ObliteratingBolt < Sorcery
      def target_choices
        battlefield.creatures + battlefield.planeswalkers
      end

      def resolve!(target:)
        trigger_effect(:deal_damage, target: target, damage: 4)
        target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
      end
    end
  end
end
