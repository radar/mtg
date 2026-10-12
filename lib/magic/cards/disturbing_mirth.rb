module Magic
  module Cards
    DisturbingMirth = Enchantment("Disturbing Mirth") do
      cost black: 1, red: 1
    end

    class DisturbingMirth < Enchantment
      # "...you may sacrifice another enchantment or creature. If you do, draw two cards."
      class SacrificeChoice < Magic::Choice::SacrificePermanent
        def prompt = "Sacrifice another enchantment or creature to draw two cards?"

        def candidates
          chooser.permanents.select { (_1.enchantment? || _1.creature?) && _1 != actor }
        end

        def resolve!(sacrifice: nil)
          super
          draw_cards(2)
        end
      end

      # "When this enchantment enters, you may sacrifice another enchantment or creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          choice = SacrificeChoice.new(actor: actor)
          game.add_choice(choice) if choice.candidates.any?
        end
      end

      # "When you sacrifice this enchantment, manifest dread."
      class SacrificedTrigger < TriggeredAbility
        def should_perform?
          event.permanent == actor
        end

        def call
          Magic::Choice::ManifestDread.perform(actor: actor)
        end
      end

      def etb_triggers = [EntersTrigger]
      def event_handlers = { Events::PermanentSacrificed => SacrificedTrigger }
    end
  end
end
