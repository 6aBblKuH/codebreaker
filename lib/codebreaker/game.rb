# frozen_string_literal: true

class Game
  DIFFICULTIES = {
    easy: { attempts: 30, hints: 3 },
    medium: { attempts: 15, hints: 2 },
    hard: { attempts: 10, hints: 1 }
  }.freeze

  attr_reader :attempts, :hints, :secret_code

  def initialize(difficulty)
    @secret_code = Array.new(4) { rand(1..6) }
    @attempts = DIFFICULTIES.dig(difficulty, :attempts)
    @hints = secret_code.shuffle.take(DIFFICULTIES.dig(difficulty, :hints))
  end

  def handle_guess(user_answer)
    @user_code = user_answer.each_char.map(&:to_i)
    handle_numbers
    @attempts -= 1
    @round_result.empty? ? 'No matches' : @round_result
  end

  def valid_answer?(user_answer)
    user_answer =~ /^[1-6]{4}$/
  end

  def take_a_hint!
    @hints.pop
  end

  def equal_codes?(user_answer)
    secret_code.join == user_answer
  end

  private

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
end
