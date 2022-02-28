module Magic
  class Game
    extend Forwardable

    attr_reader :battlefield, :choices, :stack, :players, :emblems, :current_turn

    def_delegators :@stack, :effects, :add_effect, :resolve_pending_effect, :next_effect

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
      choices: Choices.new([]),
      effects: [],
      players: []
    )
      @battlefield = battlefield
      @stack = stack
      @choices = choices
      @effects = effects
      @player_count = 0
      @players = players
      @emblems = []
      @turn_number = 0
      @current_turn = nil
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

    def tick!
      stack.resolve!
      move_dead_creatures_to_graveyard
    end

    def move_dead_creatures_to_graveyard
      battlefield.creatures.dead.each(&:destroy!)
    end
  end
end
