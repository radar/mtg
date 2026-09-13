module Magic
  module Cards
    LysAlanaHuntmaster = Creature("Lys Alana Huntmaster") do
      cost "{2}{G}{G}"
      creature_type "Elf Warrior"
      power 3
      toughness 3
    end

    class LysAlanaHuntmaster < Creature
      ElfWarriorToken = Token.create("Elf Warrior") do
        creature_type "Elf Warrior"
        power 1
        toughness 1
        colors :green
      end

      class CreateTokenChoice < Magic::Choice::May
        def resolve!
          actor.trigger_effect(:create_token, token_class: ElfWarriorToken)
        end
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          spell.type?("Elf") && you?
        end

        def call
          game.choices.add(CreateTokenChoice.new(actor: actor))
        end
      end

      def event_handlers
        { Events::SpellCast => SpellCastTrigger }
      end
    end
  end
end
