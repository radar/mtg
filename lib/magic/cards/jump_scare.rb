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
        pump(target, 2, 2)
        trigger_effect(:grant_keyword, target: target, keyword: :flying)
        target.add_types("Horror", "Enchantment")
      end
    end
  end
end
