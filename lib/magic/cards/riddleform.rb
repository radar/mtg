module Magic
  module Cards
    Riddleform = Enchantment("Riddleform") do
      cost blue: 1, generic: 1

      def event_handlers
        {
          Events::SpellCast => -> (receiver, event) do
            return if event.spell.creature?
            return if event.spell.controller != receiver.controller

            game.choices.add(Riddleform::Choice.new(source: receiver))

          end
        }
      end
    end

    class Riddleform < Enchantment
      class Choice < Magic::Choice::Effect

        def resolve!
          source.add_types(T::Creature, T::Creatures["Sphinx"])
          source.modify_base_power(3)
          source.modify_base_toughness(3)
          source.grant_keyword(Magic::Keywords::FLYING)
        end

      end
    end
  end
end
