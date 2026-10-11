module Magic
  module Cards
    VictorValgavothsSeneschal = Creature("Victor, Valgavoth's Seneschal") do
      cost generic: 1, white: 1, black: 1
      legendary_creature_type "Human Warlock"
      power 3
      toughness 3
    end

    class VictorValgavothsSeneschal < Creature
      # "...put a creature card from a graveyard onto the battlefield under your control."
      class ReanimateChoice < Magic::Choice
        def prompt = "Put a creature card from a graveyard onto the battlefield under your control."

        def choices = game.graveyard_cards.select(&:creature?)

        def resolve!(target:)
          raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

          Permanent.resolve(game: game, card: target, from_zone: target.zone, cast: false, controller: controller)
        end
      end

      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, surveil 2 if this is
      # the first time this ability has resolved this turn. If it's the second time, each opponent discards a card. If
      # it's the third time, put a creature card from a graveyard onto the battlefield under your control."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          case resolutions_this_turn
          when 1 then game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 2))
          when 2 then opponents.each { game.add_choice(Magic::Choice::Discard.new(player: _1, actor: actor)) }
          when 3
            choice = ReanimateChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        private

        # Counted as the ability resolves, not as it triggers.
        def resolutions_this_turn
          state = actor.state
          turn = game.current_turn.number
          state[:eerie_resolutions] = { turn: turn, count: 0 } unless state.dig(:eerie_resolutions, :turn) == turn
          state[:eerie_resolutions][:count] += 1
        end
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
