module Magic
  module Cards
    class RiseOfTheWitchKing < Sorcery
      card_name "Rise of the Witch-king"
      cost "{2}{B}{G}"

      # "...you may return another permanent card from your graveyard to the battlefield." Not targeted. `except` is the
      # card sacrificed this way, which "another" excludes.
      class ReturnChoice < Magic::Choice::May
        def initialize(actor:, except:)
          @except = except
          super(actor: actor)
        end

        def prompt = "Return another permanent card from your graveyard to the battlefield?"

        def choices = chooser.graveyard.cards.select { _1.permanent? && _1 != @except }

        def resolve!(card:)
          raise ArgumentError, "can't return #{card&.name.inspect}" unless choices.include?(card)

          reanimate card, controller: chooser
        end
      end

      # "Each player sacrifices a creature of their choice." The player chooses (not a target). When the caster's
      # sacrifice is made the return choice is queued, so it is answered before the opponent's sacrifice (which
      # cannot change what is in the caster's graveyard).
      class SacrificeChoice < Magic::Choice::Targeted
        def initialize(actor:, player:, returns: false)
          @player = player
          @returns = returns
          super(actor: actor)
        end

        def chooser = @player

        def targets? = false

        def choices = battlefield.controlled_by(@player).creatures

        def choice_amount = 1

        def resolve!(target:)
          card = target.card
          target.sacrifice!
          return unless @returns

          choice = ReturnChoice.new(actor: actor, except: card)
          game.add_choice(choice) if choice.choices.any?
        end

        # The sacrifice is not optional: skipping picks the first creature.
        def decline!
          resolve!(target: choices.first)
        end
      end

      def resolve!
        # Choices are answered newest first, so the caster is added last and chooses first.
        [*game.opponents(controller), controller].each do |player|
          choice = SacrificeChoice.new(actor: self, player:, returns: player == controller)
          game.add_choice(choice) if choice.choices.any?
        end
      end
    end
  end
end
