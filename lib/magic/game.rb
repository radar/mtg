module Magic
  class Game
    extend Forwardable

    attr_reader :battlefield, :exile, :choices, :stack, :players, :emblems, :current_turn

    def_delegators :@stack, :effects, :add_effect, :resolve_pending_effect, :next_effect
    def_delegators :@current_turn, :take_action, :take_actions, :can_cast_sorcery?

    def self.start!(players: [])
      new.tap do |game|
        players.each { |player| game.add_player(player) }
        game.start!
        game.next_turn
      end
    end

    def initialize(
      battlefield: Zones::Battlefield.new(owner: self),
      exile: Zones::Exile.new(owner: self),
      stack: Stack.new,
      choices: Choices.new([]),
      effects: [],
      players: []
    )
      @battlefield = battlefield
      @exile = exile
      @stack = stack
      @choices = choices
      @effects = effects
      @player_count = 0
      @players = players
      @emblems = []
      @turn_number = 0
    end

    def add_players(*players)
      players.each(&method(:add_player))
    end

    def add_player(player)
      @player_count += 1
      @players << player
      player.join_game(self)
    end

    def add_emblem(emblem)
      @emblems << emblem
    end

    def start!
      @current_turn = Turn.new(number: 1, game: self, active_player: players.first)
      players.each do |player|
        7.times { player.draw! }
      end
    end

    def notify!(*events)
      current_turn.notify!(*events)
    end

    def next_turn
      @turn_number += 1
      puts "Starting Turn #{@turn_number} - Active Player: #{@players.first}"
      @current_turn = Turn.new(number: @turn_number, game: self, active_player: @players.first)
      next_active_player
      @current_turn
    end

    def next_active_player
      @players = players.rotate(1)
    end

    def opponents(player)
      players - [player]
    end

    def any_target
      battlefield.creatures + battlefield.planeswalkers + players
    end

    def tick!
      stack.resolve!
      move_dead_creatures_to_graveyard
    end

    def move_dead_creatures_to_graveyard
      battlefield.creatures.dead.each do |creature|
        puts "#{creature.name} died, moving to graveyard."
        creature.destroy!
      end
    end
  end
end
