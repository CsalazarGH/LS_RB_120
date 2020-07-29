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

  def ai_mover(marker)
    move = nil
    WINNING_LINES.each do |line|
      markers = [@squares[line[0]].marker, @squares[line[1]].marker, @squares[line[2]].marker] 
      if markers.count(marker) == 2 && markers.count(INITIAL_MARKER) == 1
        move = line[markers.index(' ')]
      end
    end
    move
  end

  def full?
    @squares.values.all? { |object| object.marker != INITIAL_MARKER }
  end

  def empty?
    @squares.all? { |_, object| object.marker == INITIAL_MARKER }
  end

  def middle_empty?
    @squares[5].marker == INITIAL_MARKER
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
  attr_accessor :score, :marker, :name

  def initialize
    @marker = nil
    @score = 0
    @name = nil
    set_name
  end

  def set_name
    puts "What is your name?"
    @name = gets.chomp.downcase
  end
end

class Computer < Player
  attr_accessor :score, :marker
  attr_reader :name

  def set_name
    @name = ['R2D2', 'ROBOT', 'TTTBOT', 'LaunchSCHOOLBOT'].sample
  end
end

class TTTGame
  attr_reader :board, :human, :computer

  def initialize
    @board = Board.new
    @human = Player.new
    @computer = Computer.new
    @turn = nil
    @first
  end

  def display_welcome_message
    puts "Welcome to Tic-Tac-Toe #{human.name.upcase}!"
  end

  def display_goodbye_message
    puts "Goodbye! Thanks for playing!"
  end

  def display_board
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
    board[ans] = human.marker
  end

  def computer_moves  
    num = if board.ai_mover(computer.marker) 
            board.ai_mover(computer.marker)
          elsif board.ai_mover(human.marker) 
            board.ai_mover(human.marker)
          elsif board.middle_empty?
            5
          else
            board.empty_squares.sample
          end
    board[num] = computer.marker
  end

  def board_full?
    board.full?
  end

  def someone_won_round?
    [human.marker, computer.marker].include?(board.detect_winner)
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

  def display_round_result
    human_message = "#{human.name.upcase} won this round!"
    computer_message = "#{computer.name.upcase} won this round!"
    tie_message = "Nobody won! Tie!"
    winner_marker = board.detect_winner

    case winner_marker
    when human.marker then puts human_message
    when computer.marker then puts computer_message
    else puts tie_message
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

  def match_winner?
    [human.score, computer.score].include?(5)
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
    @first = ans
  end

  def increment_winner_score
    winner_marker = board.detect_winner

    case winner_marker
    when human.marker then human.score += 1
    when computer.marker then computer.score += 1
    end
  end

  def next_round
    puts "Press any key to move onto the next round!"
    1.times {gets.chomp}
  end

  def display_score
    puts "SCORES are #{human.name.upcase}: #{human.score} - #{computer.name.upcase}: #{computer.score}"
  end

  def display_match_winner
    if human.score > computer.score
      puts "#{human.name.upcase} IS THE WINNER!"
    else
      puts "#{computer.name.upcase} IS THE WINNER!"
    end
    display_score
  end

  def reset_game
    human.score = 0
    computer.score = 0
    @board = Board.new
    @turn = nil
    @first = nil
    @computer.marker = nil
    @human.marker = nil
    clear_terminal
  end

  def new_round
    next_round
    @board = Board.new
    @turn = @first
    clear_terminal
  end

  def display_player_markers
    puts "Player Markers:"
    puts "#{human.name.upcase} IS #{human.marker} - #{computer.name.upcase} IS #{computer.marker}"
    puts ""
  end

  def display_final_results
    display_board
    display_match_winner
  end

  def human_turn?
    @turn == 'human'
  end

  def x_or_o
    ans = nil
    puts "Would you like to be X or O"
    loop do
      ans = gets.chomp.downcase
      break if ['x', 'o'].include?(ans)
      puts "Please enter X or O"
    end
    human.marker = ans.upcase
    computer.marker = if human.marker == 'X'
                        'O'
                      else
                        'X'
                      end
  end

  def play
    clear_terminal
    display_welcome_message
      loop do # LOOP 1 - THIS LOOP WILL RUN AS LONG AS THE PLAYER WANTS TO PLAY NEW MATCHES
        goes_first?
        x_or_o
        clear_terminal
        display_player_markers
        loop do # LOOP 2 - - THIS LOOP WILL GO FOR 5 ROUNDS AND THEN BREAK
          current_player_moves
          display_board if human_turn?
          increment_winner_score
          break if match_winner?
          if someone_won_round? || board_full?
            display_board
            display_round_result
            display_score
            new_round
            next
          end
        end #LOOP 2 END 
        clear_terminal
        display_final_results
        if play_again?
          reset_game
          next
        end
        break
      end  # LOOP 1 ENDs                 
  end 
end

game = TTTGame.new
game.play
