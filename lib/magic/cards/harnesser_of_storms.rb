module Magic
  module Cards
    HarnesserOfStorms = Creature("Harnesser of Storms") do
      cost generic: 2, red: 1
      creature_type("Otter Wizard")
      power 1
      toughness 4
    end

    class HarnesserOfStorms < Creature
      # Whenever you cast a noncreature or Otter spell, you may exile the top card of your library. Until end of
      # turn, you may play that card. This ability triggers only once each turn.
      class CastTrigger < TriggeredAbility::SpellCast
        class MayExile < Magic::Choice::May
          def resolve!
            top = controller.library.first or return

            exile_target(top)
            game.play_permissions.grant_until_end_of_turn(card: top, player: controller)
          end
        end

        def should_perform?
          event.player == controller && (!spell.creature? || spell.type?("Otter")) && !actor.triggered_once_this_turn?(self.class)
        end

        def trigger!
          return false unless should_perform?

          actor.trigger_once_this_turn!(self.class)
          true
        end

        def call
          game.choices.add(MayExile.new(actor: actor))
        end
      end

      def event_handlers = super.merge(Events::SpellCast => CastTrigger)
    end
  end
end
