module Magic
  module Cards
    UtterInsignificance = Aura("Utter Insignificance") do
      cost generic: 1, blue: 1
      keywords :flash
    end

    class UtterInsignificance < Aura
      enchant "Creature"

      def target_choices
        battlefield.creatures
      end

      def static_abilities = [Insignificance]

      # "Enchanted creature loses all abilities and has base power and toughness 1/1."
      class Insignificance < Abilities::Static::CharacteristicSetting
        applies_to_target
        sets_base_power_and_toughness 1, 1
        loses_all_abilities
      end

      # "{2}{C}: Exile enchanted creature."
      class ExileAbility < Magic::ActivatedAbility
        costs "{2}{C}"

        def resolve!
          exile_target(source.attached_to)
        end
      end

      def activated_abilities = [ExileAbility]
    end
  end
end
