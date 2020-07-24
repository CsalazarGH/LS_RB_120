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
      puts "What's you're name?"
      n = gets.chomp
      break unless n.empty?
      puts "sorry please enter a name."
    end
    self.name = n.capitalize
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, spock, lizard:"
      choice = gets.chomp.downcase
      break if CHOICES.include?(choice)
      puts "Invalid Choice, choose again."
    end
    self.move = [Rock.new, Paper.new, Scissors.new, Spock.new, Lizard.new][CHOICES.index(choice)]
  end
end

class Computer < Player
  PERSONALITIES = { 'Robot' => [Rock.new, Paper.new, Scissors.new, Spock.new, Lizard.new],
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
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
    @@moves_log = []
  end

  def display_welcome_message
    puts "Welcome to the game #{human.name}!"
  end

  def displayer_welcome_message
    puts "Welcome to Rock Paper Scissors! (Lizard-Spock Edition)"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}!"
    puts "#{computer.name} chose #{computer.move}!"
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won! #{human.move} beats #{computer.move}!"
    elsif computer.move > human.move
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
    human.score == 10 || computer.score == 10
  end

  def display_match_winner
    if human.score == 10
      display_score
      puts "THE HUMAN WINS THIS ROUND!"
    else
      display_score
      puts "THE COMPUTER WINS THIS ROUND!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (Y or N)"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Please enter Y or N."
    end
    answer == 'y' ? true : false
  end

  def log_moves
    @@moves_log << "HUMAN MOVE: #{human.move} - COMP MOVE: #{computer.move}"
  end

  def display_moves_log
    puts @@moves_log
  end

  def game_final_methods
    display_match_winner
    human.score = 0
    computer.score = 0
    display_moves_log if view_moves_log?
    @@moves_log = []
    puts '-' * 15
  end

  def view_moves_log?
    ans = ''
    loop do
      puts "Would you like to view the moves log?(Y or N):"
      ans = gets.chomp.downcase
      break if ['y', 'n'].include?(ans)
      puts "Please enter Y or N"
    end
    ans == 'y'
  end

  def round_methods
    human.choose # HUMAN PLAYER CHOOSES MOVE
    computer.choose # COMPUTER CHOOSES MOVE
    system('clear') || system('cls') # CLEARS TERMINAL
    display_moves # DISPLAYS PLAYERS MOVES
    display_winner # DISPLAYERS WINNER
    increment_scores # INCREASES WINNER SCORE BY 1
    log_moves # ADDS MOVES TO LOG
  end

  def play
    display_welcome_message
    loop do # MAIN GAME LOOP
      round_methods
      display_score unless winner?
      if winner?
        game_final_methods
        break unless play_again?
      end
      next
    end
  end
end

RPSGame.new.play
