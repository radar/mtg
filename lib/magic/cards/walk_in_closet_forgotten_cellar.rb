module Magic
  module Cards
    class WalkInClosetForgottenCellar < Room
      class WalkInCloset < Room::Door
        card_name "Walk-In Closet"
        cost generic: 2, green: 1

        # "You may play lands from your graveyard."
        class PlayLandsFromGraveyard < StaticAbility
          def permits_casting_from_graveyard?(card, player)
            player == controller && card.land? && card.zone == player.graveyard
          end
        end

        def static_abilities = [PlayLandsFromGraveyard]
      end

      class ForgottenCellar < Room::Door
        card_name "Forgotten Cellar"
        cost generic: 3, green: 2

        # "If a card would be put into your graveyard from anywhere this turn, exile it instead." Registered on the Room for
        # the turn.
        class ExileInsteadOfYourGraveyard < ReplacementEffect
          def applies?(effect)
            return false unless effect.to.graveyard? && effect.to.owner == receiver.controller

            # A token isn't a card.
            !(effect.target.is_a?(Permanent) && effect.target.token?)
          end

          def call(effect)
            if effect.target.is_a?(Permanent)
              Effects::ExilePermanent.new(source: receiver, target: effect.target)
            else
              Effects::ExileCard.new(source: receiver, target: effect.target)
            end
          end
        end

        # "When you unlock this door, you may cast spells from your graveyard this turn, and if a card would be put into
        # your graveyard from anywhere this turn, exile it instead."
        when_unlocked do
          controller.graveyard.cards.to_a.each do |card|
            game.play_permissions.grant_until_end_of_turn(card: card, player: controller, from_graveyard: true)
          end
          actor.register_turn_replacement(Effects::MoveCardZone, ExileInsteadOfYourGraveyard)
          actor.register_turn_replacement(Effects::MovePermanentZone, ExileInsteadOfYourGraveyard)
        end
      end

      doors WalkInCloset, ForgottenCellar
    end
  end
end
