# frozen_string_literal: true

class Game
  DIFFICULTY = {
    easy: { attempts: 30, hints: 3 },
    medium: { attempts: 15, hints: 2 },
    hard: { attempts: 10, hints: 1 }
  }.freeze

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
    make_secret_code
    game_round
  end

  def choose_the_difficulty
    answer = @console.question 'choose the difficulty lvl'
    difficulty(answer)
  end

  def difficulty(diff)
    lvl = DIFFICULTY[diff.to_sym]
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
    @user_answer = @console.round_question(@attempts_count)
    handle_answer
  end

  def handle_answer
    if @user_answer == 'hint'
      hint
      game_round if @attempts_count > 0
    elsif validate_answer
      @attempts_count -= 1
      handle_code
      game_round if @attempts_count > 0
    else
      game_round if @attempts_count > 0
    end
  end

  def handle_code
    user_code = []
    @user_answer.each_char { |chr| user_code << chr.to_i }
    if @attempts_count.positive?
      if compare_codes(user_code)
        @console.win
        @attempts_count = 0
      end
    else
      @console.loose(@secret_code)
    end
  end

  def validate_answer
    return true if @user_answer =~ /^[1-6]{4}$/
    @console.invalid_number
  end

  def hint
    msg = @hints_count.zero? ? @console.phrases[:no_hint] : take_a_hint!
    @console.message(msg)
  end

  def take_a_hint!
    @hints_count -= 1
    @hints.pop
  end

  def compare_codes(user_code)
    return true if @secret_code == user_code
    result = ''
    uncatched_numbers = []
    @secret_code.each_index do |index|
      if @secret_code[index] == user_code[index]
        result += '+'
        user_code[index] = nil
      else
        uncatched_numbers << @secret_code[index]
      end
    end

    user_code.compact.each do |number|
      if uncatched_numbers.include?(number)
        uncatched_numbers.delete_at(uncatched_numbers.index(number))
        result += '-'
      end
    end
    @console.message(result) unless result.empty?
    false
  end

  def one_more?
    answer = @console.question 'one more? (y/n)'
    msg = if %w[y yes].include? answer.downcase
            'nu go'
          else
            'ty for game'
    end
    @console.message(msg)
  end

  def secret_code
    @secret_code ||= make_secret_code
  end

  private
  def make_secret_code
    4.times { @secret_code << rand(1..6) }
    @hints = @secret_code.shuffle
    @secret_code
  end
end
