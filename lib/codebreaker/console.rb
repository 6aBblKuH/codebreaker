# frozen_string_literal: true



class Console
  PHRASES_PATH = 'lib/codebreaker/src/phrases.yml'.freeze

  attr_reader :phrases
  def initialize
    @phrases = YAML.load_file(PHRASES_PATH)
  end

  def message(val)
    puts val
  end

  def question(q)
    puts q
    gets.chomp
  end

  def rules
    message(@phrases[:rules])
  end

  def difficulty_rules
    @phrases[:difficulty].each do |diff, descr|
      message("#{diff}: #{descr}")
    end
  end

  def welcome
    message @phrases[:welcome]
  end

  def round_question(attempts)
    question("#{@phrases[:round_question]}#{attempts.to_s}")
  end

  def invalid_number
    message @phrases[:invalid_number]
  end

  def win
    message @phrases[:win]
  end

  def loose(secret_code)
    message @phrases[:loose] << secret_code.join
  end
end
