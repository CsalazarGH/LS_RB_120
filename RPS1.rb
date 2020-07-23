class Move
  VALUES = ['rock', 'paper', 'scissors']

  def initialize(value)
    @value = value
  end

  def scissors?
    @value == 'scissors'
  end

  def rock?
    @value == 'rock'
  end

  def paper?
    @value == 'paper'
  end

  def >(other)
    rock? && other.scissors? ||
      paper? && other.rock? ||
      scissors? && other.paper?
  end

  def <(other)
    rock? && other.paper? ||
      paper? && other.scissors? ||
      scissors? && other.rock?
  end

  def to_s
    @value
  end
end

class Player
  attr_accessor :move, :name, :score

  def initialize
    set_name
    @score = 0 
  end
end

class Human < Player
  def set_name
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
      puts "Please choose rock, paper, scissors:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Invalid Choice, choose again."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = ['Robot', 'R2D2', 'RPSBOT'].sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to the game!"
  end

  def display_goodbye_message
    puts "Thanks for playing!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      human.score += 1
      puts "#{human.name} won!"
    elsif  human.move < computer.move
      computer.score += 1
      puts "#{computer.name} won!"
    else
      puts "It's a tie!"
    end
  end

  def display_score
    puts "Score is HUMAN: #{human.score} - COMPUTER: #{computer.score}"
  end

  def display_round_winner
    if human.score == 10
      puts "Score is HUMAN: #{human.score} - COMPUTER: #{computer.score}, HUMAN WINS"
    else
      puts "Score is HUMAN: #{human.score} - COMPUTER: #{computer.score}, COMPUTER WINS"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again?"
      answer = gets.chomp.downcase
      break if ['y', 'n'].include?(answer)
      puts "Please enter Y or N."
    end
    answer == 'y' ? true : false
  end

  def winner?
    human.score == 10 || computer.score == 10
  end

  def play
    display_welcome_message
    loop do
      human.choose
      computer.choose
      display_moves
      display_winner
      display_score
      puts '-------------------'
      if winner?
        display_round_winner
        human.score = 0 
        computer.score = 0
        break unless play_again?
      end
      next
    end
    display_goodbye_message
  end
end

RPSGame.new.play
