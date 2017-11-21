require_relative "console"
require "pry"
class Game

  attr_accessor :secret_code
  def initialize
    @secret_code = []
    @attempts_count = 20
    @console = Console.new
    game_round
  end

  def game_round
    @attempts_count -= 1
    @user_answer = @console.question('Put the numbers')
    handle_answer
  end

  def handle_answer
    validate_answer
    user_code = []
    @user_answer.each_char { |chr| user_code << chr.to_i }
    if @attempts_count > 0
      compare_codes(user_code) ? win : game_round
    else
      loose
    end
  end

  def validate_answer
    @console.message 'Put only numbers' if /[^0-9]/ =~ @user_answer
    @console.message 'Put 4-digital number' if @user_answer.length != 4
  end

  def compare_codes(user_code)
    if secret_code == user_code
      @console.message ('ebat ty krasavella')
      return true
    end
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
        result << "-"
      end
    end
    @console.message(result) unless result.empty?
    false
  end

  def secret_code
    @secret_code.empty? ? make_secret_code : @secret_code
  end

  def win
    @console.message 'Congrat. U did it'
  end

  def loose
    @console.message 'What do we say God of Games? Not today'
  end

  def one_more?
    answer = @console.question 'one more?'
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
    @secret_code
  end


end
Game.new
# binding.pry
