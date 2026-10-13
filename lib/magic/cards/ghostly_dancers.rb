module Magic
  module Cards
    GhostlyDancers = Creature("Ghostly Dancers") do
      cost generic: 3, white: 2
      creature_type "Spirit"
      keywords :flying
      power 2
      toughness 5
    end

    class GhostlyDancers < Creature
      SpiritToken = Token.create "Spirit" do
        creature_type "Spirit"
        colors :white
        keywords :flying
        power 3
        toughness 1
      end

      # "...return an enchantment card from your graveyard to your hand..." (not a target)
      class ReturnEnchantmentChoice < Magic::Choice
        def prompt = "Return an enchantment card from your graveyard to your hand."

        def choices = graveyard.cards.select(&:enchantment?)

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

          target.move_to_hand!
        end
      end

      # "When this creature enters, return an enchantment card from your graveyard to your hand or unlock a locked door
      # of a Room you control." Resolve with `mode: :return` or `mode: :unlock`.
      class ModeChoice < Magic::Choice
        RETURN = :return
        UNLOCK = :unlock

        def prompt = "Return an enchantment card from your graveyard to your hand, or unlock a locked door of a Room you control."

        def modes
          {
            RETURN => "Return an enchantment card from your graveyard to your hand",
            UNLOCK => "Unlock a locked door of a Room you control",
          }
        end

        def choices
          [
            (RETURN if ReturnEnchantmentChoice.new(actor: actor).choices.any?),
            (UNLOCK if Magic::Choice::UnlockDoor.new(actor: actor).choices.any?),
          ].compact
        end

        def resolve!(mode:)
          raise ArgumentError, "#{mode.inspect} is not a valid choice" unless choices.include?(mode)

          case mode
          when RETURN then game.add_choice(ReturnEnchantmentChoice.new(actor: actor))
          when UNLOCK then game.add_choice(Magic::Choice::UnlockDoor.new(actor: actor))
          end
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          choice = ModeChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, create a 3/1 white
      # Spirit creature token with flying."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          create_token(token:SpiritToken)
        end
      end

      def etb_triggers = [EntersTrigger]
      def event_handlers = EerieTrigger.handlers
    end
  end
end
