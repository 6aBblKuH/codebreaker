require_relative "console"
require "pry"

class Game

  Difficulty = {
    easy: {attempts: 30, hints: 3 },
    medium: {attempts: 15, hints: 2 },
    hard: {attempts: 10, hints: 1 }
  }

  attr_accessor :secret_code
  def initialize
    @secret_code = []
    @console = Console.new
    # welcome
    new_game
  end

  def welcome
    @console
  end

  def new_game
    @console.rules
    @console.difficulty_rules
    choose_the_difficulty
    secret_code
    game_round
  end

  def choose_the_difficulty
    answer = @console.question 'choose the difficulty lvl'
    difficulty(answer)
  end

  def difficulty(diff)
    lvl = Difficulty[diff.to_sym]
    if lvl
      setup_the_difficulty(lvl)
    else
       @console.message('Spelling failure')
       choose_the_difficulty
    end
  end

  def setup_the_difficulty(lvl)
    @attempts_count = lvl[:attempts]
    @hints_count = lvl[:hints]
  end

  def game_round
    @user_answer = @console.question("Put the numbers. You`ve got #{@attempts_count} attempts")
    handle_answer
  end

  def handle_answer
    if @user_answer == 'hint'
      hint
    elsif validate_answer
      @attempts_count -= 1
      handle_code
    end
    game_round if @attempts_count > 0
  end

  def handle_code
    user_code = []
    @user_answer.each_char { |chr| user_code << chr.to_i }
    if @attempts_count > 0
      @console.win if compare_codes(user_code)
    else
      @console.loose(@secret_code)
    end
  end

  def validate_answer
    @console.message 'Put only numbers' if /[^0-9]/ =~ @user_answer
    @console.message 'Put 4-digital number' if @user_answer.length != 4
    true if @user_answer.length == 4 && !@user_answer.match( /[^0-9]/ )
  end

  def hint
    msg = if @hints_count > 0
      @hints_count -= 1
      @hints.pop
    else
      'Hints are over'
    end
    @console.message(msg)
  end

  def compare_codes(user_code)
    return true if secret_code == user_code
    result = ''
    uncatched_numbers = []
    @secret_code.each_index do |index|
      if @secret_code[index] == user_code[index]
        result << "+"
        user_code[index] = nil
      else
        uncatched_numbers << @secret_code[index]
      end
    end

    user_code.compact.each do |number|
      if uncatched_numbers.include?(number)
        uncatched_numbers.delete(number)
        result << "-"
      end
    end
    @console.message(result) unless result.empty?
    false
  end

  def secret_code
    @secret_code.empty? ? make_secret_code : @secret_code
  end

  def one_more?
    answer = @console.question 'one more? (y/n)'
    msg = if ['y', 'yes'].include? answer.downcase
      'nu go'
    else
     'ty for game'
    end
    @console.message(msg)
  end

  protected
  def make_secret_code
    4.times { @secret_code << rand(1..6) }
    @hints = @secret_code.shuffle
    @secret_code
  end


end
game = Game.new
