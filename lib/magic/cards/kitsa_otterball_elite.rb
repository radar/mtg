module Magic
  module Cards
    KitsaOtterballElite = Creature("Kitsa, Otterball Elite") do
      legendary_creature_type "Otter Wizard"
      cost generic: 1, blue: 1
      keywords :vigilance, :prowess
      power 1
      toughness 3
    end

    class KitsaOtterballElite < Creature
      # {T}: Draw a card, then discard a card.
      class LootAbility < Magic::ActivatedAbility
        costs "{T}"

        def resolve!
          draw_card
          game.choices.add(Magic::Choice::Discard.new(actor: source, player: controller)) if controller.hand.any?
        end
      end

      # {2}, {T}: Copy target instant or sorcery spell you control. You may choose new targets for the copy.
      # Activate only if Kitsa's power is 3 or greater.
      class CopyAbility < Magic::ActivatedAbility
        costs "{2}, {T}"

        def requirements_met? = source.power >= 3

        def target_choices
          game.stack.spells.select { |spell| spell.player == controller && (spell.card.instant? || spell.card.sorcery?) }
        end

        def resolve!(target:)
          Magic::CopyEffect.resolve_with_choice!(actor: source, receiver: target.card, targets: target.targets)
        end
      end

      def activated_abilities = [LootAbility, CopyAbility]
    end
  end
end
