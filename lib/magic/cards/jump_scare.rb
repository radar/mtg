module Magic
  module Cards
    class JumpScare < Instant
      card_name "Jump Scare"
      cost white: 1

      def target_choices
        creatures
      end

      # "Until end of turn, target creature gets +2/+2, gains flying, and becomes a Horror enchantment creature in
      # addition to its other types."
      def resolve!(target:)
        trigger_effect(:modify_power_toughness, power: 2, toughness: 2, target: target, until_eot: true)
        trigger_effect(:grant_keyword, target: target, keyword: :flying)
        target.add_types("Horror", "Enchantment")
      end
    end
  end
end
