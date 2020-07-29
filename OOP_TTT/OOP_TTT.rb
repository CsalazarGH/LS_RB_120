require 'pry'

class Board
  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9],
                   [1, 4, 7], [2, 5, 8], [3, 6, 9],
                   [1, 5, 9], [3, 5, 7]]
  INITIAL_MARKER = ' '

  def initialize
    @squares = {}
    (1..9).each { |key| @squares[key] = Square.new(INITIAL_MARKER) }
  end

  def []=(num, marker)
    @squares[num].marker = marker
  end

  def full?
    @squares.values.all? { |object| object.marker != INITIAL_MARKER }
  end

  def empty?
    @squares.all? { |_, object| object.marker == INITIAL_MARKER }
  end

  def empty_squares
    @squares.select { |_, object| object.marker == INITIAL_MARKER }.keys
  end

  def detect_winner
    WINNING_LINES.each do |line|
      squares = [@squares[line[0]], @squares[line[1]], @squares[line[2]]]
      line_markers = squares.map { |square| square.marker }
      if (squares.all? { |square| square.marked? }) && line_markers.uniq.size == 1
        return squares[0].marker
      end
    end
  end

  def draw
    puts ""
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}  "
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}  "
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}  "
    puts "     |     |"
    puts ""
  end
end

class Square
  attr_accessor :marker

  def initialize(marker)
    @marker = marker
  end

  def marked?
    marker != ' '
  end

  def to_s
    marker
  end
end

class Player
  attr_reader :marker

  def initialize(marker)
    @marker = marker
  end
end

class TTTGame
  HUMAN_MARKER = "X"
  COMPUTER_MARKER = "O"
  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new(HUMAN_MARKER)
    @computer = Player.new(COMPUTER_MARKER)
    @turn = nil
  end

  def display_welcome_message
    puts "Welcome to Tic-Tac-Toe!"
  end

  def display_goodbye_message
    puts "Goodbye! Thanks for playing!"
  end

  def display_board
    puts "You're a #{human.marker}, Computer is #{computer.marker}"
    puts ""
    board.draw
    puts ""
  end

  def commas_or(array)
    case array.size
    when 1 then array.first
    when 2 then array.join(' or ')
    else array[0..-2].join(', ') + ' or' + " #{array[-1]}"
    end
  end

  def human_moves
    ans = ''
    puts "Choose a square: #{commas_or(board.empty_squares)}"
    loop do
      ans = gets.chomp.to_i
      break if board.empty_squares.include?(ans)
      puts "Invalid Input. Choose a square: #{commas_or(board.empty_squares)}"
    end
    board[ans] = HUMAN_MARKER
  end

  def computer_moves
    num = board.empty_squares.sample
    board[num] = COMPUTER_MARKER
  end

  def board_full?
    board.full?
  end

  def someone_won?
    [HUMAN_MARKER, COMPUTER_MARKER].include?(board.detect_winner)
  end

  def play_again?
    answer = ''
    puts "Would you like to play again? (Y or N):"
    loop do
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Please enter Y or N"
    end
    answer == 'y'
  end

  def display_result
    human_message = "Human won this game!"
    computer_message = "Computer won this game!"
    winner_marker = board.detect_winner

    case winner_marker
    when HUMAN_MARKER then puts human_message
    when COMPUTER_MARKER then puts computer_message
    end
  end

  def clear_terminal
    system('clear') || system('cls')
  end

  def reset_game
    @board = Board.new
    @turn = nil
    clear_terminal
    puts "Lets play again!"
  end

  def current_player_moves
    if @turn == 'human'
      human_moves
      @turn = 'computer'
    else
      computer_moves
      @turn = 'human'
    end
  end

  def game_round
    loop do
      current_player_moves
      break if someone_won? || board_full?
      display_board
    end
  end

  def goes_first?
    ans = nil
    puts "Who goes first? Enter Human or Computer:"
    loop do
      ans = gets.chomp.downcase
      break if ['human', 'computer'].include?(ans)
      puts "Please enter Human or Computer"
    end
    @turn = ans
  end

  def play
    clear_terminal
    display_welcome_message
    loop do
      goes_first? if board.empty?
      display_board
      game_round
      display_board
      display_result
      if play_again?
        reset_game
        next
      else
        display_goodbye_message
        break
      end
    end
  end
end

game = TTTGame.new
game.play