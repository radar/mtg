module Magic
  module Cards
    MirkwoodMeditator = Creature("Mirkwood Meditator") do
      cost generic: 2, blue: 1
      creature_type "Elf Druid"
      power 2
      toughness 4
    end

    class MirkwoodMeditator < Creature
      # "Landfall -- Whenever a land you control enters, you may have this creature's base power and
      # toughness become 4/2 until end of turn."
      class LandfallTrigger < TriggeredAbility::Landfall
        class MayChoice < Magic::Choice::May
          def resolve!
            actor.modify_base_power(4)
            actor.modify_base_toughness(2)
          end
        end

        def should_perform?
          event.player == controller
        end

        def call
          game.add_choice(MayChoice.new(actor: actor))
        end
      end

      def event_handlers
        super.merge({ Events::Landfall => LandfallTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
