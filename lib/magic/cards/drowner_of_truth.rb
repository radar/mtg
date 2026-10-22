module Magic
  module Cards
    # The land back face of Drowner of Truth. It has no mana cost.
    DrownedJungle = Card("Drowned Jungle") do
      type "Land"
    end

    class DrownedJungle < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :green, :blue
      end

      def activated_abilities = [ManaAbility]
    end

    DrownerOfTruth = Creature("Drowner of Truth") do
      cost "{5}{G/U}{G/U}"
      creature_type "Eldrazi"
      power 7
      toughness 6
      keywords :devoid
      back_face DrownedJungle
    end

    class DrownerOfTruth < Creature
      # "When you cast this spell, if {C} was spent to cast it, create two 0/1 colorless Eldrazi Spawn creature
      # tokens with 'Sacrifice this token: Add {C}.'"
      class CastTrigger < TriggeredAbility::CastThisSpell
        def should_perform? = spent(:colorless).positive?

        def call = create_eldrazi_spawn(2)
      end

      def cast_triggers = [CastTrigger]
    end
  end
end
