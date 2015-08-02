require 'byebug'

class Card
  attr_reader :face_value, :face_up

  def initialize(face_value)
    @face_value = face_value
    @face_up = false
  end

  def hide
    if face_up
      @face_up = false
    end
  end

  def reveal
    if !face_up
      @face_up = true
    end
  end

  def to_s
    if face_up
      face_value.to_s
    else
      " "
    end
  end

  def ==(other_card)
    other_card.face_value == face_value
  end
end

class Board
  attr_reader :grid, :height, :width, :cards

  def initialize(playable_cards, bombs_on)
    bombs = bombs_on ? make_bombs(playable_cards.length) : []
    @cards = playable_cards + bombs
    @grid = make_grid
    @height = @grid.length
    @width = @grid[0].length
  end

  def make_grid
    factors = factors(cards.length)
    if factors.length.even?
      width = factors[factors.length / 2]
      height = factors[(factors.length / 2) - 1]
    else
      width = factors[factors.length / 2]
      height = width
    end

    Array.new(height) { Array.new(width) }
  end

  def make_bombs(num_playable_cards)
    num_bombs = num_playable_cards / 6
    total_cards = num_playable_cards + num_bombs
    until factors(total_cards).length > 2
      num_bombs -= 1
      total_cards = num_playable_cards + num_bombs
    end
    bombs = []
    num_bombs.times do
      bombs << Card.new("!")
    end
    return bombs
  end

  def factors(num)
    factors = []
    i = 1
    while i <= num
      factors << i if num % i == 0
      i += 1
    end
    factors
  end

  def populate
    shuffled_cards = @cards.shuffle
    (0...@grid.length).each do |row_index|
      (0...@grid[0].length).each do |cell_index|
        @grid[row_index][cell_index] = shuffled_cards.pop
      end
    end
  end

  def render
    system("clear")
    @grid.each do |row|
      row.each do |cell|
        print "[#{cell.to_s}]"
      end
      print "\n"
    end
  end

  def render_bombs
    system("clear")
    @grid.each do |row|
      row.each do |cell|
        to_print = cell.face_value == "!" ? "!" : " "
        print "[#{to_print}]"
      end
      print "\n"
    end
    sleep(5)
  end

  def won?
    @grid.each do |row|
      row.each do |cell|
        return false if !cell.face_up && cell.face_value != "!"
      end
    end

    true
  end

  def [](pos)
    @grid[pos[0]][pos[1]]
  end

  def not_in_grid?(pos)
    !pos[0].between?(0, height - 1) || !pos[1].between?(0, width - 1)
  end

  def bomb_exploded?
    @grid.each do |row|
      row.each do |cell|
        return true if cell.face_up && cell.face_value == "!"
      end
    end

    false
  end
end

class Game
  attr_reader :board, :num_turns_remaining, :bombs_on, :num_unique_cards,
    :player

  def initialize(opts = {})
    defaults = {player: HumanPlayer.new, num_unique_cards: 8, bombs_on: true}
    opts = defaults.merge(opts)
    @num_unique_cards = opts[:num_unique_cards]
    @player = opts[:player]
    @board = Board.new(pack_of_cards, opts[:bombs_on])
    @previous_pos = nil
    @num_turns_remaining = num_unique_cards * 2
  end

  def pack_of_cards
    output_cards = []
    letter = "a"
    num_unique_cards.times do
      2.times { output_cards << Card.new(letter) }
      new_code = letter.ord + 1
      letter = new_code.chr
    end
    output_cards
  end

  def play
    board.populate
    player.receive_board_size(board.height, board.width)
    board.render_bombs
    player.receive_bombs(bomb_positions)
    loop do
      display_progress
      if board.bomb_exploded? || num_turns_remaining == 0
        puts "You lost!"
        break
      elsif board.won?
        puts "You won!"
        break
      end
      make_guess
    end
  end


  def bomb_positions
    result = []
    (0...board.height).each do |row_index|
      (0...board.width).each do |col_index|
        pos = [row_index, col_index]
        result << pos if board[pos].face_value == "!"
      end
    end
    result
  end

  def display_progress
    @board.render
    puts "Turns remaining: #{num_turns_remaining}"
  end

  def make_guess
    guess_pos = @player.get_input
    return if @board.not_in_grid?(guess_pos) || @board[guess_pos].face_up
    @board[guess_pos].reveal
    @player.receive_revealed_card(@board[guess_pos].face_value, guess_pos)
    display_progress
    sleep(1)
    if @previous_pos.nil?
      @previous_pos = guess_pos
    else
      if @board[guess_pos] == @board[@previous_pos]
        @player.receive_match(guess_pos, @previous_pos)
      else
        @board[guess_pos].hide
        @board[@previous_pos].hide
      end
      @previous_pos = nil
      @num_turns_remaining -= 1
    end
  end


end

class HumanPlayer
  def get_input
    puts "Next pos?"
    input = $stdin.gets.chomp
    input.split(",").map {|num_str| num_str.to_i}
  end

  def receive_revealed_card(face_value, pos)
  end

  def receive_match(first_pos, second_pos)
  end

  def receive_board_size(board_height, board_width)
  end

  def receive_bombs(bomb_positions)
  end

end

class ComputerPlayer
  def initialize
    @known_cards = {}
    @visited_positions = []
    @matched_cards = []
    @board_height = nil
    @board_width = nil
    @previous_pos = nil
  end

  attr_reader :previous_pos, :known_cards

  def get_input
    if previous_pos.nil?
      if cards_to_be_matched
        return cards_to_be_matched[rand(2)]
      else
        return random_unvisited_position
      end
    elsif position_with_same_face_value(previous_pos)
      return position_with_same_face_value(previous_pos)
    else
      return random_unvisited_position
    end
  end

  def position_with_same_face_value(pos)
    @known_cards.values.each do |locations|
      if locations.length > 1 && locations.include?(pos)
        return locations.select { |el| el != pos }[0]
      end
    end

    nil
  end

  def random_unvisited_position
    loop do
      random_row = rand(@board_height)
      random_col = rand(@board_width)
      pos = [random_row, random_col]
      return pos unless @visited_positions.include?(pos) ||
        known_cards["!"].include?(pos)
    end
  end

  def cards_to_be_matched
    @known_cards.each do |face_value, positions|
      return positions if face_value != "!" && positions.length == 2 &&
        !@matched_cards.include?(positions[0])
    end

    nil
  end

  def receive_bombs(bomb_positions)
    @known_cards["!"] = []
    bomb_positions.each do |bomb_pos|
      @known_cards["!"] << bomb_pos
    end
  end

  def receive_revealed_card(face_value, pos)
    if @known_cards[face_value].nil?
      @known_cards[face_value] = []
    end
    @known_cards[face_value] << pos
    @visited_positions << pos
    if previous_pos.nil?
      @previous_pos = pos
    else
      @previous_pos = nil
    end
  end

  def receive_match(first_pos, second_pos)
    @matched_cards << first_pos
    @matched_cards << second_pos
  end

  def receive_board_size(board_height, board_width)
    @board_height = board_height
    @board_width = board_width
  end
end

if __FILE__ == $PROGRAM_NAME
  if ARGV[0]
    game = Game.new(num_unique_cards: ARGV[0].to_i)
  else
    game = Game.new
  end
  game.play
end
