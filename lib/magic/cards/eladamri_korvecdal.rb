module Magic
  module Cards
    EladamriKorvecdal = Creature("Eladamri, Korvecdal") do
      cost "{1}{G}{G}"
      legendary_creature_type "Elf Warrior"
      power 3
      toughness 3
    end

    class EladamriKorvecdal < Creature
      # "You may look at the top card of your library any time." and "You may cast creature spells from the top of your
      # library." The engine has no hook for private looks, so `may_look_at_top_card?` is only a marker.
      class TopLibraryPermission < StaticAbility
        def may_look_at_top_card?(player)
          player == controller
        end

        def permits_casting_from_top?(card)
          player_controls = card.owner == controller
          player_controls && card == controller.library.first && card.creature?
        end
      end

      # "Reveal a card from your hand or the top card of your library." Answer with `resolve_choice!(card:)`.
      class RevealChoice < Magic::Choice
        def controller = actor.controller

        def choices
          [*controller.hand.cards, controller.library.first].compact
        end

        def prompt = "Reveal a card from your hand or the top card of your library."

        def resolve!(card:)
          raise "Invalid card to reveal" unless choices.include?(card)

          reveal_cards [card]
          return unless card.creature?

          Permanent.put_onto_battlefield(game: game, card: card, from_zone: card.zone, controller: controller)
        end
      end

      # "{G}, {T}, Tap two untapped creatures you control: Reveal a card from your hand or the top card of your library.
      # If you reveal a creature card this way, put it onto the battlefield. Activate only during your turn."
      class RevealAbility < Magic::ActivatedAbility
        def costs
          [
            *Costs::Parser.parse(source: source, costs: "{G}, {T}"),
            Costs::MultiTap.new(2) { controller.creatures.untapped.except(source) }
          ]
        end

        def requirements_met? = game.current_turn.active_player == controller

        def resolve!
          choice = RevealChoice.new(actor: source)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def static_abilities = [TopLibraryPermission]
      def activated_abilities = [RevealAbility]
    end
  end
end
