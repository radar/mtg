module Magic
  module Cards
    UrenisRebuff = Sorcery("Ureni's Rebuff") do
      cost generic: 1, blue: 1
      harmonize Costs::Mana.new(generic: 5, blue: 1)
    end

    class UrenisRebuff < Sorcery
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        bounce(target)
      end
    end
  end
end
