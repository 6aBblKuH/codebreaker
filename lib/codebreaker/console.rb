# frozen_string_literal: true
require_relative 'statistic'


class Console
  include Statistic

  PHRASES_PATH = 'lib/codebreaker/src/phrases.yml'.freeze

  attr_reader :phrases

  def initialize
    @phrases = YAML.load_file(PHRASES_PATH)
  end

  def output(message)
    puts message.is_a?(Symbol) ? @phrases[message] : message
  end

  def ask(question)
    output(question) if question
    gets.chomp
  end

  def dichotomy_question?(question)
    answer = ask(question).downcase
    %w[yes y yeap].include?(answer)
  end

  def rules
    output(:rules)
    difficulty_rules
  end

  def output_statistics
    handle_statistics_for_output.each { |record| output(record) }
  end

  def round_question(attempts)
    ask("#{@phrases[:round_question]}#{attempts.to_s}")
  end

  def loose(secret_code)
    output(@phrases[:loose] << secret_code.join)
  end

  private

  def difficulty_rules
    Game::DIFFICULTIES.each do |diff_name, params|
      output("#{diff_name}: #{params[:attempts]} attempts and #{params[:hints]} hints")
    end
  end
end
