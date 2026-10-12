module Magic
  module Cards
    TheQueenOfDale = Creature("The Queen of Dale") do
      cost generic: 1, white: 1
      legendary_creature_type "Human Noble"
      power 2
      toughness 1
    end

    class TheQueenOfDale < Creature
      # "Whenever an opponent casts their first noncreature spell each turn, you recruit."
      class RecruitTrigger < TriggeredAbility::SpellCast
        def should_perform?
          return false unless opponents.include?(event.player) && !spell.creature?

          # The current spell is already in the turn's log.
          game.current_turn.spells_cast.count { _1.player == event.player && !_1.spell.creature? } == 1
        end

        def call
          Magic::Recruit.call(player: controller)
        end
      end

      def event_handlers = super.merge({ Events::SpellCast => RecruitTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
