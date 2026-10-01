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
        trigger_effect(:deal_damage, target: target, damage: 2)
      end
    end
  end
end
