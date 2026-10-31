module Magic
  module Cards
    SurroundedByOrcs = Sorcery("Surrounded by Orcs") do
      cost generic: 3, blue: 1
    end

    class SurroundedByOrcs < Sorcery
      def target_choices = game.players

      # "Amass Orcs 3, then target player mills X cards, where X is the amassed Army's power."
      def resolve!(target:)
        army = Magic::Amass.call(source: self, controller: controller, amount: 3, subtype: "Orc")
        if army
          # Counters change power only once continuous effects are recomputed.
          army.apply_continuous_effects!
          target.mill(army.power)
        end
        super()
      end
    end
  end
end
