module Magic
  module Cards
    WarpedTusker = Creature("Warped Tusker") do
      cost generic: 7
      creature_type "Eldrazi Boar Beast"
      keywords :reach
      power 6
      toughness 8
    end

    class WarpedTusker < Creature
      # Cycling {2}{G}
      cycling "{2}{G}"

      # When you cast this spell, create a 0/1 Eldrazi Spawn token.
      class CastTrigger < TriggeredAbility::CastThisSpell
        def call = create_eldrazi_spawn
      end

      def cast_triggers = [CastTrigger]

      # When you cycle this card, create a 0/1 Eldrazi Spawn token (and draw, from cycling itself).
      def cycling_effect!
        create_eldrazi_spawn(controller: owner)
        super
      end
    end
  end
end
