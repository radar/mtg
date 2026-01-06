module Magic
  module Cards
    Riddleform = Enchantment("Riddleform") do
      cost blue: 1, generic: 1
    end

    class Riddleform < Enchantment
      class SpellcastTrigger < TriggeredAbility
        def should_perform?
          !event.spell.creature? && you?
        end

        def call
          game.add_choice(Riddleform::Choice.new(actor: actor))
        end
      end

      class Choice < Magic::Choice
        def resolve!
          actor.add_types(T::Creature, T::Creatures["Sphinx"])
          actor.modify_base_power(3)
          actor.modify_base_toughness(3)
          actor.grant_keyword(Magic::Keywords::FLYING)
        end
      end

      def event_handlers
        {
          Events::SpellCast => SpellcastTrigger
        }
      end
    end
  end
end
