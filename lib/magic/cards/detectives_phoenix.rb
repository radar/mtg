module Magic
  module Cards
    DetectivesPhoenix = Creature("Detective's Phoenix") do
      enchantment_creature_type("Phoenix")
      cost generic: 2, red: 1
      bestow Costs::Mana.new(red: 1)
      keywords :flying, :haste
      power 2
      toughness 2
    end

    class DetectivesPhoenix < Creature
      # "Bestow--{R}, Collect evidence 6": see `Actions::Cast::Bestowed#collect_evidence`.
      def bestow_collect_evidence = 6

      # "You may cast this card from your graveyard using its bestow ability."
      def bestow_from_graveyard? = true

      # "Enchanted creature gets +2/+2 and has flying and haste."
      def power_modification = 2

      def toughness_modification = 2

      def keyword_grants = [Keywords::FLYING, Keywords::HASTE]
    end
  end
end
