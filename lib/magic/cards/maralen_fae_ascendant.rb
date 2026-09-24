module Magic
  module Cards
    MaralenFaeAscendant = Creature("Maralen, Fae Ascendant") do
      cost generic: 2, black: 1, green: 1, blue: 1
      legendary_creature_type("Elf Faerie Noble")
      keywords :flying
      power 4
      toughness 5
    end

    class MaralenFaeAscendant < Creature
      # "Whenever Maralen or another Elf or Faerie you control enters, exile the top two
      # cards of target opponent's library."
      class ElfOrFaerieEntersTrigger < TriggeredAbility::EnterTheBattlefield
        class TargetChoice < Magic::Choice::Targeted
          def choices = game.opponents(controller)
          def choice_amount = 1

          def resolve!(target:)
            target.library.first(2).each { actor.exile_with_this!(_1) }
          end
        end

        def should_perform?
          this? || (under_your_control? && any_type?("Elf", "Faerie"))
        end

        def call
          choice = TargetChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "Once each turn, you may cast a spell with mana value less than or equal to the
      # number of Elves and Faeries you control from among cards exiled with Maralen this
      # turn without paying its mana cost."
      class FreeCastPermission < StaticAbility
        def permits_casting_from_exile?(card, player)
          player == controller && !card.land? && !@source.triggered_once_this_turn?(:free_cast) &&
            @source.exiled_with_this_this_turn?(card) && card.mana_value <= elves_and_faeries
        end

        def free_cast_from_exile?(card, player)
          permits_casting_from_exile?(card, player)
        end

        private

        def elves_and_faeries = controller.permanents.by_any_type("Elf", "Faerie").count
      end

      # Uses up the once-each-turn free cast.
      class FreeCastUsed < TriggeredAbility
        def should_perform?
          event.player == controller && actor.exiled_with_this_this_turn?(event.spell)
        end

        def call
          actor.trigger_once_this_turn!(:free_cast)
        end
      end

      # The enters trigger handles Maralen entering too (`this?`), so it's only an event handler.
      def static_abilities = [FreeCastPermission]

      def event_handlers
        { Events::EnteredTheBattlefield => ElfOrFaerieEntersTrigger, Events::SpellCast => FreeCastUsed }
      end
    end
  end
end
