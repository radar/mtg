module Magic
  module Cards
    GoblinPlateMail = Equipment("Goblin Plate Mail") do
      cost generic: 1, black_or_red: 1
      equip [Costs::Mana.new(generic: 4)]

      # "When this Equipment enters, amass Goblins 1, then attach this Equipment to the amassed Army."
      enters_the_battlefield do
        army = Magic::Amass.call(source: actor, controller: controller, amount: 1)
        actor.attach_to!(army) if army
      end
    end

    class GoblinPlateMail < Equipment
      class PowerBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 0
        applies_to_target
      end

      class MenaceGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::MENACE
        applies_to_target
      end

      def static_abilities = [PowerBuff, MenaceGrant]
    end
  end
end
