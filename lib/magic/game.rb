module Magic
  class Game
    include AASM
    extend Forwardable

    attr_reader :battlefield, :stack, :players, :emblems, :current_turn, :after_step_triggers

    def_delegators :@stack, :effects, :add_effect, :resolve_effect, :next_effect

    class Trigger
      attr_reader :action, :until_eot

      def initialize(action:, until_eot:)
        @action = action
        @until_eot = until_eot
      end

      def until_eot?
        until_eot
      end

      def resolve(game)
        action.resolve(game)
      end
    end

    def self.start!(players: [])
      new.tap do |game|
        players.each { |player| game.add_player(player) }
        game.start!
        game.next_turn
      end
    end

    def initialize(
      battlefield: Zones::Battlefield.new(owner: self),
      stack: Stack.new,
      effects: [],
      players: []
    )
      @battlefield = battlefield
      @stack = stack
      @effects = effects
      @player_count = 0
      @players = players
      @emblems = []
      @turn_number = 0
      @current_turn = nil
      @after_step_triggers = Hash.new { |h, k| h[k] = [] }
    end

    def after_step(step, action, until_eot: true)
      @after_step_triggers[step] << Trigger.new(
        action: action,
        until_eot: until_eot,
      )
    end

    def add_player(player)
      @player_count += 1
      @players << player
      player.join_game(self)
    end

    def add_static_ability(ability)
      battlefield.static_abilities.add(ability)
      battlefield.cards.apply_ability(ability)
    end

    def remove_static_abilities_from(card)
      abilities = battlefield.static_abilities.from(card)
      abilities.each do |ability|
        battlefield.static_abilities.remove(ability)
      end
    end

    def add_emblem(emblem)
      @emblems << emblem
    end

    def start!
      players.each do |player|
        7.times { player.draw! }
      end
    end

    def notify!(*events)
      current_turn.notify!(*events)
    end

    def next_turn
      @turn_number += 1
      @current_turn = Turn.new(number: @turn_number, game: self, active_player: @players.first)
    end

    def next_active_player
      @players = players.rotate(1)
    end

    def deal_damage_to_opponents(player, damage)
      opponents = players - [player]
      opponents.each { |opponent| opponent.take_damage(damage) }
    end
  end
end
