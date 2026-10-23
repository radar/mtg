module Magic
  module Cards
    ReiteratingBolt = Sorcery("Reiterating Bolt") do
      cost generic: 1, red: 1
      replicate_energy 3
    end

    class ReiteratingBolt < Sorcery
      def target_choices = game.battlefield.creatures + game.battlefield.planeswalkers

      def resolve!(target:)
        deal_damage(3, to: target)
      end
    end
  end
end
