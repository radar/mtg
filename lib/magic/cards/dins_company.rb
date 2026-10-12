module Magic
  module Cards
    DinsCompany = Creature("Dáin's Company") do
      cost red: 1, white: 1
      creature_type("Dwarf Warrior")
      power 2
      toughness 2
    end

    class DinsCompany < Creature
      class SelfKeywords < Abilities::Static::KeywordGrant
        keyword_grants Keywords::LIFELINK
        applicable_targets { [source] }
        conditions { controller.permanents.by_type("Dwarf").except(source).any? }
      end

      def static_abilities = [SelfKeywords]

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::LookAtTopCards.new(actor: actor, amount: 4, filter: ->(card) { card.any_type?("Dwarf", "Equipment") }))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
