class Move
  attr_reader :value

  WIN = { 'rock' => ['lizard', 'scissors'],
          'paper' => ['spock', 'rock'],
          'scissors' => ['paper', 'lizard'],
          'lizard' => ['spock', 'paper'],
          'spock' => ['scissors', 'rock'] }

  def to_s
    @value.capitalize
  end

  def >(other)
    WIN[value].include?(other.value)
  end
end

class Rock < Move
  def initialize
    @value = 'rock'
  end
end

class Paper < Move
  def initialize
    @value = 'paper'
  end
end

class Scissors < Move
  def initialize
    @value = 'scissors'
  end
end

class Lizard < Move
  def initialize
    @value = 'lizard'
  end
end

class Spock < Move
  def initialize
    @value = 'spock'
  end
end

class Player
  CHOICES = ['rock', 'paper', 'scissors', 'spock', 'lizard']
  CLASSES = [Rock.new, Paper.new, Scissors.new, Spock.new, Lizard.new]

  attr_accessor :name, :move, :score

  def initialize
    set_name
    @score = 0
  end
end

class Human < Player
  def set_name # HUMAN SET NAME METHOD
    n = nil
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "sorry please enter a name."
    end
    self.name = n.capitalize
  end

  def choose
    choice = nil
    puts "Please choose rock, paper, scissors, spock, lizard:"
    loop do
      choice = gets.chomp.downcase
      break if CHOICES.include?(choice)
      puts "Invalid Choice. Choose Rock, paper, scissors, spock or Lizard"
    end
    self.move = CLASSES[CHOICES.index(choice)]
  end
end

class Computer < Player
  PERSONALITIES = { 'Robot' => CLASSES,
                    'R2D2' => [Rock.new, Paper.new, Scissors.new, Lizard.new],
                    'RPSBOT' => [Rock.new] }

  def set_name
    self.name = ['Robot', 'R2D2', 'RPSBOT'].sample
  end

  def choose
    self.move =  case name
                 when 'Robot' then PERSONALITIES['Robot'].sample
                 when 'R2D2' then PERSONALITIES['R2D2'].sample
                 when 'RPSBOT' then PERSONALITIES['RPSBOT'].sample
                 end
  end
end

class RPSGame
  attr_accessor :human, :computer, :rounds_number

  def initialize
    @human = Human.new
    @computer = Computer.new
    @moves_log = []
    @rounds_number = nil
  end

  def two_option_answer(string, options, type)
    ans = ''
    puts string
    loop do
      ans = case type
            when 'str' then gets.chomp.downcase
            else gets.chomp.to_i
            end
      break if options.include?(ans)
      puts "Please enter #{options.join(' or ')}."
    end
    ans
  end

  def display_welcome_message
    puts "Welcome to the game #{human.name}!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}!"
    puts "#{computer.name} chose #{computer.move}!"
  end

  def human_won?
    human.move > computer.move
  end

  def computer_won?
    computer.move > human.move
  end

  def display_winner
    if human_won?
      puts "#{human.name} won! #{human.move} beats #{computer.move}!"
    elsif computer_won?
      puts "#{computer.name} won! #{computer.move} beats #{human.move}!"
    else
      puts "It was a tie! Nobody won"
    end
  end

  def increment_scores
    if human.move > computer.move
      human.score += 1
    elsif computer.move > human.move
      computer.score += 1
    end
  end

  def display_score
    puts "Score is HUMAN: #{human.score} - COMPUTER: #{computer.score}"
  end

  def winner?
    human.score == @rounds_number || computer.score == @rounds_number
  end

  def display_match_winner
    display_score
    if human.score == @rounds_number
      puts "THE HUMAN WINS THIS ROUND!"
    else
      puts "THE COMPUTER WINS THIS ROUND!"
    end
  end

  def play_again?
    string = "Would you like to play again? (Y or N)"
    answer = two_option_answer(string, ['y', 'n'], 'str')
    answer == 'y'
  end

  def log_moves
    @moves_log << "HUMAN MOVE: #{human.move} - COMP MOVE: #{computer.move}"
  end

  def display_moves_log
    puts @moves_log
  end

  def game_final_methods
    display_match_winner
    human.score = 0
    computer.score = 0
    display_moves_log if view_moves_log?
    @moves_log = []
    @rounds_number = nil
    puts '------------------------------'
  end

  def view_moves_log?
    string = "Would you like to view the moves log?(Y or N):"
    answer = two_option_answer(string, ['y', 'n'], 'str')
    answer == 'y'
  end

  def clear_terminal
    system('clear') || system('cls')
  end

  def game_round
    human.choose
    computer.choose
    clear_terminal
    display_moves
    display_winner
    increment_scores
    log_moves
  end

  def choose_winning_number
    string = "How many rounds to win? 5 or 10?"
    number = two_option_answer(string, [5, 10], 'int')
    @rounds_number = number.to_i
  end

  def play
    display_welcome_message
    loop do
      choose_winning_number if @moves_log.empty?
      game_round
      display_score unless winner?
      if winner?
        game_final_methods
        break unless play_again?
        clear_terminal
      end
      next
    end
  end
end

RPSGame.new.play
