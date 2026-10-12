module Magic
  module Cards
    DaringWaverider = Creature("Daring Waverider") do
      cost generic: 4, blue: 2
      creature_type("Otter Wizard")
      power 4
      toughness 4
    end

    class DaringWaverider < Creature
      # When this creature enters, you may cast target instant or sorcery card with mana value 4 or less from your
      # graveyard without paying its mana cost. If that spell would be put into your graveyard, exile it instead.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class CastChoice < Magic::Choice::Targeted
          def choices = controller.graveyard.select { (_1.instant? || _1.sorcery?) && _1.mana_value <= 4 }

          def choice_amount = 1

          def resolve!(target:)
            Magic::Choice::FreeCast.start(actor: actor, card: target)
          end
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            choice = CastChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
