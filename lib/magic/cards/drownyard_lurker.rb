module Magic
  module Cards
    DrownyardLurker = Creature("Drownyard Lurker") do
      cost generic: 7
      creature_type "Eldrazi Trilobite"
      keywords :vigilance
      power 7
      toughness 7
    end

    class DrownyardLurker < Creature
      # Cycling {2}{U}
      cycling "{2}{U}"

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
