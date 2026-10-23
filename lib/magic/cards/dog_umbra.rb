module Magic
  module Cards
    class DogUmbra < Aura
      card_name "Dog Umbra"
      cost generic: 1, white: 1
      keywords :flash

      enchant "Creature"

      def target_choices = battlefield.creatures

      # "As long as another player controls enchanted creature, it can't attack or block. Otherwise, this Aura has umbra armor."
      def forbids_enchanted_combat?(host, aura) = host.controller != aura.controller

      def umbra_armor?(host, aura) = host.controller == aura.controller
    end
  end
end
