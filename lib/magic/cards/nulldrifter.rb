module Magic
  module Cards
    Nulldrifter = Creature("Nulldrifter") do
      cost generic: 7
      creature_type "Eldrazi Elemental"
      keywords :flying, Keywords::Annihilator.new(1)
      evoke "{2}{U}"
      power 4
      toughness 4
    end

    class Nulldrifter < Creature
      # "When you cast this spell, draw two cards."
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call = draw_cards(2)
      end

      def cast_triggers = [CastTrigger]
    end
  end
end
