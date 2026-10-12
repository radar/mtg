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
        deal_damage(4, to: target)
        target.register_turn_replacement(Magic::Effects::MovePermanentZone, Magic::ReplacementEffect::ExileInsteadOfDying)
      end
    end
  end
end
