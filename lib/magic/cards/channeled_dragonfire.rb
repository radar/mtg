module Magic
  module Cards
    ChanneledDragonfire = Sorcery("Channeled Dragonfire") do
      cost red: 1
      harmonize Costs::Mana.new(generic: 5, red: 2)
    end

    class ChanneledDragonfire < Sorcery
      def target_choices
        game.any_target
      end

      def resolve!(target:)
        deal_damage(2, to: target)
      end
    end
  end
end
