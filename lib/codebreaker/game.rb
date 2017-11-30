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
    handle_difficulty(answer)
  end

  def handle_difficulty(diff)
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
    while @attempts_count > 0
      @user_answer = @console.round_question(@attempts_count)
      handle_answer
    end
  end

  def handle_answer
    if @user_answer == 'hint'
      hint
    elsif validate_answer
      handle_code
    end
  end

  def handle_code
    @user_code = @user_answer.split('')
    if compare_codes
      win
    else
      handle_guess
      @attempts_count -= 1
      @console.loose(@secret_code) if @attempts_count.zero?
    end
  end

  def handle_guess
    @round_result = ''
    uncatched_numbers = check_numbers_for_correct_position.compact
    check_numbers_with_incorrect_position(uncatched_numbers)
    @console.message(@round_result) unless @round_result.empty?
  end

  def check_numbers_for_correct_position
    @secret_code.map.with_index do |element, index|
      if element == @user_code[index]
        @round_result += '+'
        @user_code[index] = nil
      else
        element
      end
    end
  end

  def check_numbers_with_incorrect_position(uncatched_numbers)
    (@user_code.compact & uncatched_numbers).size.times { @round_result += '-' }
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

  def compare_codes
    @secret_code == @user_code
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

  private

  def make_secret_code
    4.times { @secret_code << rand(1..6).to_s }
    @hints = @secret_code.shuffle
    @secret_code
  end

  def win
    @console.win
    @attempts_count = 0
  end
end
