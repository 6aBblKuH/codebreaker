# frozen_string_literal: true

class Game
  DIFFICULTIES = {
    easy: { attempts: 30, hints: 3 },
    medium: { attempts: 15, hints: 2 },
    hard: { attempts: 10, hints: 1 }
  }.freeze

  def initialize
    console.output(:welcome)
    welcome_instructions
  end

  private

  def welcome_instructions
    case console.ask(:welcome_instruction).downcase
    when 'game' then new_game
    when 'stats' then statistics
    when 'exit' then exit
    else
      console.output(:spelling_error)
      welcome_instructions
    end
  end

  def new_game
    console.rules
    handle_difficulty
    game_round
  end

  def statistics
    console.output_statistics
    welcome_instructions
  end

  def handle_difficulty
    @difficulty_name = console.ask(:choose_difficulty).to_sym
    return if DIFFICULTIES.key? @difficulty_name
    console.output(:spelling_error)
    handle_difficulty
  end

  def game_round
    while attempts.positive?
      @user_answer = console.round_question(attempts)
      next hint if @user_answer == 'hint'
      return win if equal_codes?
      valid_answer? ? handle_guess : console.output(:invalid_number)
    end
    lose
  end

  def handle_guess
    @user_code = @user_answer.each_char.map(&:to_i)
    handle_numbers
    console.output(@round_result) unless @round_result.empty?
    @attempts -= 1
  end

  def check_numbers_for_correct_position
    secret_code.map.with_index do |element, index|
      next element unless element == @user_code[index]
      @user_code[index] = nil
    end
  end

  def handle_numbers
    uncatched_numbers = check_numbers_for_correct_position
    @round_result = '+' * uncatched_numbers.select(&:nil?).size
    @user_code.compact.map do |number|
      next unless uncatched_numbers.compact.include?(number)
      @round_result += '-'
      uncatched_numbers[uncatched_numbers.index(number)] = nil
    end
  end

  def valid_answer?
    @user_answer =~ /^[1-6]{4}$/
  end

  def hint
    msg = hints.empty? ? :no_hint : take_a_hint!
    console.output(msg)
  end

  def take_a_hint!
    @hints.pop
  end

  def equal_codes?
    secret_code.join == @user_answer
  end

  def attempts
    @attempts ||= DIFFICULTIES.dig(@difficulty_name, :attempts)
  end

  def hints
    @hints ||= secret_code.shuffle.take(DIFFICULTIES.dig(@difficulty_name, :hints))
  end

  def console
    @console ||= Console.new
  end

  def secret_code
    @secret_code ||= Array.new(4) { rand(1..6) }
  end

  def win
    console.output(:win)
    Loader.save_score(score_data) if console.dichotomy_question?(:save_score)
    console.dichotomy_question?(:new_game) ? Game.new : console.output(:goodbye)
  end

  def score_data
    name = console.ask(:username)
    { name: name, difficulty: @difficulty_name, attempts: attempts, hints: hints.size }
  end

  def lose
    console.loose(secret_code)
    console.dichotomy_question?(:new_game) ? Game.new : console.output(:goodbye)
  end
end
