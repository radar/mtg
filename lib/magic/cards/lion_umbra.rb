module Magic
  module Cards
    class LionUmbra < Aura
      card_name "Lion Umbra"
      cost green: 2

      # "Enchant modified creature". The Aura itself is a modification, so it stays attached once it is on the creature.
      def can_enchant?(host, aura:) = host.respond_to?(:creature?) && host.creature? && host.modified?

      def target_choices = battlefield.creatures.select(&:modified?)

      # "Enchanted creature gets +3/+3 and has reach and vigilance."
      def power_modification = 3

      def toughness_modification = 3

      def keyword_grants = [Keywords::REACH, Keywords::VIGILANCE]

      def umbra_armor?(_host, _aura) = true
    end
  end
end
