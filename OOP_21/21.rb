class Deck
  def initialize
    @cards = new_deck
  end

  def new_deck
    Card::CARD_SUITS.product(Card::CARD_RANKS).map {|card_info| Card.new(card_info)}
  end
  
  def pull_card(num=1)
    pulled = @cards.sample(num)
    pulled.each {|card| @cards.delete(card)}
    pulled
  end
end

class Card
attr_reader :suit, :rank

CARD_RANKS = (2..10).to_a + ['J', 'Q', 'K', 'A']
CARD_SUITS = ['S', 'D', 'C', 'H']

  def initialize(card_info)
    @suit = card_info[0]
    @rank = card_info[1]
  end

  def queen?
    rank == 'Q'
  end

  def king? 
    rank == 'K'
  end

  def jack?
    rank == 'J'
  end

  def ace? 
    rank == 'A'
  end

  def honor_card?
    ace? || jack? || king? || queen?
  end

  def display
    "#{convert_rank} of #{convert_suit}"
  end

  def convert_suit
    ['Spades', 'Diamonds', 'Clubs', 'Hearts'].select {|str| str[0] == @suit[0]}[0]
  end

  def convert_rank  
    if honor_card?
      ['Jack', 'Queen', 'King', 'Ace'].select {|str| str[0] == @rank[0]}[0]
    else
      @rank
    end
  end

end

class Participant
  attr_accessor :hand

  def initialize
    @hand = []
    @score = 0
    @name = nil
    set_name
  end

  def add_cards(cards)
    cards.each do |card|
      @hand << card
    end
  end

  def hand_value
    aces = hand.select {|card| card.ace?}
    aces.map!.with_index {|obj, idx| idx == 0 ? 11 : 1 }

    others = hand.select {|card| !card.ace?}
    others.map! {|card| card.honor_card? ? 10 : card.rank }

    aces.sum + others.sum
  end

  def display_cards
    @hand.map {|card| card.display}
  end

  def bust?
    hand_value > 21
  end

  def clear_hand
    @hand = []
  end
end

class Player < Participant
  def set_name
    name = ''
    puts "Please enter your name:"
    loop do
      name = gets.chomp.capitalize
      break if name != ''
      puts "Please enter a name."
    end
    @name = name
  end
end

class Dealer < Participant
  def set_name
    @name = ['R2D2', 'ROBOT', '21BOT', 'LSBOT']
  end

  def have_17?
    hand_value >= 17
  end 
end

class Game
  attr_reader :deck, :human, :dealer

  def initialize
    @deck = Deck.new
    @human = Player.new
    @dealer = Dealer.new
    deal_initial_cards
  end

  def game_reset
    @deck = Deck.new
    clear_hands
    deal_initial_cards
  end

  def clear_terminal
    system('clear') || system('cls')
  end
  
  def clear_hands
    human.clear_hand
    dealer.clear_hand
  end

  def deal_initial_cards
    human_initial_cards = deck.pull_card(2)
    dealer_initial_cards = deck.pull_card(2)

    human.add_cards(human_initial_cards)
    dealer.add_cards(dealer_initial_cards)
  end

  def hit(person)
    new_card = deck.pull_card
    person.add_cards(new_card)
  end

  def prompt(mssg)
    puts "=> #{mssg}"
  end

  def two_option_answer(mssg, options)
    answer = ''
    prompt(mssg)
    loop do
      answer = gets.chomp.downcase
      break if options.include?(answer)
      prompt("Please enter #{options.map(&:upcase).join(' or ')}")
    end
    answer
  end

  def line
    '-'*50
  end

  def joinor(cards)
    case cards.size
    when 1 then cards.join(', ')
    when 2 then cards.join (' and ')
    else cards[0..-2].join(', ') + ' and ' + cards[-1]
    end
  end

  def display_welcome_message
    prompt("Welcome to the game of TWENTY-ONE!")
    prompt(line)
  end

  def start_game?
    prompt("Press ENTER to start the game!")
    gets.chomp
  end

  def next_card
    prompt("Dealer is going to HIT!")
    prompt("Press ENTER to see next card dealt!")
    gets.chomp
  end

  def display_human_hand
    prompt("Your hand is #{joinor(human.display_cards)}")
    prompt("Your hand value is #{human.hand_value}, YOU BUSTED!") if human.bust?
    prompt("Your hand value is #{human.hand_value}") if !human.bust?
    prompt(line)
  end

  def display_dealer_hand(unknown=true, value=true)
    unknown_sentence = dealer.display_cards[0] + ' and unknown card.'
    visible = joinor(dealer.display_cards)
   
    prompt("DEALER's hand is #{unknown ? unknown_sentence : visible}")
    prompt("DEALER's hand value is #{dealer.hand_value}") if value
    prompt(line)
  end

  def hit_or_stay?
    message = "Would you like to hit or stay?"
    two_option_answer(message, ['h', 's'])
  end

  def nobody_bust
    !human.bust? && !dealer.bust?
  end

  def display_winner_or_tie
    case human.hand_value <=> dealer.hand_value
    when 1 then prompt("YOU WON! #{human.hand_value} - #{dealer.hand_value}")
    when -1 then prompt("DEALER WON! #{dealer.hand_value} - #{human.hand_value}")
    else prompt("IT WAS A TIE! #{human.hand_value} - #{dealer.hand_value}")
    end
  end

  def display_results
    prompt("YOU BUSTED! YOU LOSE!") if human.bust?
    prompt("DEALER BUSTED! DEALER LOSES!") if dealer.bust?
    display_winner_or_tie if nobody_bust
  end

  def play_again?
    mssg = "Would you like to play again? (Y or N):"
    two_option_answer(mssg, ['y', 'n']) == 'n'
  end

  def display_goodbye_message
    prompt("GOODBYE! THANKS FOR PLAYING!")
  end

  def human_loop
    loop do #HUMAN LOOP START
      clear_terminal
      display_dealer_hand(true, false)
      display_human_hand
      break if human.bust?
      if hit_or_stay? == 'h'
        hit(human)
        next
      else
        break
      end
    end #HUMAN LOOP END
  end
  
  def dealer_loop
    loop do #DEALER LOOP 
      clear_terminal
      display_dealer_hand(false, true)
      break if dealer.bust? || dealer.have_17?
      hit(dealer)
      next_card
    end #DEALER LOOP END
  end

  def main_loop
    loop do 
      human_loop
      break if human.bust?
      dealer_loop
      break
    end 
  end

  def play
    clear_terminal
    display_welcome_message
    loop do
      clear_terminal
      start_game?
      main_loop
      display_results
      game_reset
      break if play_again?
    end
    display_goodbye_message
  end

end

Game.new.play