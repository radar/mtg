module Magic
  module Cards
    GimlisAxe = Equipment("Gimli's Axe") do
      cost generic: 2, red: 1
      equip [Costs::Mana.new(generic: 2)], sorcery_speed: true
    end

    class GimlisAxe < Equipment
      # "Equipped creature gets +3/+0."
      class Buff < Abilities::Static::PowerAndToughnessModification
        modify power: 3, toughness: 0
        applies_to_target
      end

      # "As long as equipped creature is legendary, it has menace."
      class LegendaryMenace < Abilities::Static::KeywordGrant
        keyword_grants Keywords::MENACE

        def applicable_targets = [source.attached_to].compact.select(&:legendary?)
      end

      def static_abilities = [Buff, LegendaryMenace]
    end
  end
end
