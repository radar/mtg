module Magic
  module Cards
    class SayItsName < Sorcery
      card_name "Say Its Name"
      cost generic: 1, green: 1

      # "Mill three cards. Then you may return a creature or land card from your graveyard to your hand."
      def resolve!
        controller.mill(3)
        choice = Magic::Choice::ReturnFromAmong.new(
          actor: self,
          cards: controller.graveyard.cards.to_a,
          filter: ->(card) { card.creature? || card.land? }
        )
        game.choices.add(choice) if choice.choices.any?
      end

      # "Search your graveyard, hand, and/or library for a card named Altanak, the Thrice-Called and put it onto the
      # battlefield." Answer with the Altanak to put onto the battlefield (or `target: nil` to find none).
      class AltanakChoice < Magic::Choice
        NAME = "Altanak, the Thrice-Called"

        def prompt = "Search your graveyard, hand and library for #{NAME}."

        def choices
          [*chooser.graveyard.cards, *chooser.hand.cards, *chooser.library.cards].select { _1.name == NAME }
        end

        # If you search your library this way, shuffle.
        def resolve!(target: nil)
          raise ArgumentError, "#{target.name} isn't #{NAME}" if target && !choices.include?(target)

          from_library = target&.zone&.library?
          Permanent.put_onto_battlefield(game: game, card: target, from_zone: target.zone, controller: chooser) if target
          chooser.library.shuffle! if from_library
        end
      end

      # "Exile this card and two other cards named Say Its Name from your graveyard: Search your graveyard, hand, and/or
      # library for a card named Altanak, the Thrice-Called and put it onto the battlefield. If you search your library
      # this way, shuffle. Activate only as a sorcery."
      class GraveyardAbility < Magic::ActivatedAbility
        def costs
          [Costs::ExileFromGraveyard.new(source, count: 3, named: "Say Its Name", includes_source: true)]
        end

        def requirements_met?
          source.zone&.graveyard? && source.owner == controller && game.can_cast_sorcery?(controller)
        end

        def resolve!
          game.add_choice(AltanakChoice.new(actor: source))
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
