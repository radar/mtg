module Magic
  module Cards
    class Dub < Card
      NAME = "Dub"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 2, white: 1 }

      def resolve!
        attach_enchantment = Effects::AttachEnchantment.new(enchantment: self, choices: game.battlefield.creatures)
        game.add_effect(attach_enchantment)
      end

      def apply_attachment_effects(creature)
        creature.modifiers << Creature::Buff.new(power: 2, toughness: 2)
        creature.grant_keyword(Keywords::FIRST_STRIKE)
        creature.grant_type("Knight")
      end
    end
  end
end
