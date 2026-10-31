module Magic
  module Cards
    class FearFireFoes < Sorcery
      card_name "Fear, Fire, Foes!"
      cost x: 1, red: 1

      def target_choices = battlefield.creatures

      # "Damage can't be prevented this turn. Fear, Fire, Foes! deals X damage to target creature and 1 damage to each
      # other creature with the same controller."
      def resolve!(target:, value_for_x: 0)
        game.current_turn.damage_cant_be_prevented!
        others = battlefield.creatures.controlled_by(target.controller).reject { _1 == target }
        deal_damage(value_for_x, to: target)
        others.each { deal_damage(1, to: _1) }
      end
    end
  end
end
