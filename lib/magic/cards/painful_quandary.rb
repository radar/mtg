module Magic
  module Cards
    PainfulQuandary = Enchantment("Painful Quandary") do
      cost generic: 3, black: 2
    end

    class PainfulQuandary < Enchantment
      class OpponentSpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          opponent?
        end

        def call
          [that_player].each { |player| game.add_choice(Magic::Choice::LoseLifeUnless.new(actor: actor, player: player, life: 5, discard: true)) }
        end
      end

      def event_handlers = { Events::SpellCast => OpponentSpellCastTrigger }
    end
  end
end
