module Magic
  module Cards
    GothmogMorgulLieutenant = Creature("Gothmog, Morgul Lieutenant") do
      cost generic: 3, black: 1
      legendary_creature_type "Human Soldier"
      power 3
      toughness 3

      # "When Gothmog enters, amass Orcs 1."
      enters_the_battlefield do
        Magic::Amass.call(source: actor, controller: controller, amount: 1, subtype: "Orc")
      end
    end

    class GothmogMorgulLieutenant < Creature
      # "Creature tokens you control have deathtouch."
      class TokensDeathtouch < Abilities::Static::KeywordGrant
        keyword_grants Keywords::DEATHTOUCH
        applicable_targets { source.controller.creatures.select(&:token?) }
      end

      def static_abilities = [TokensDeathtouch]
    end
  end
end
