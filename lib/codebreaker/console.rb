# frozen_string_literal: true

module Codebreaker

  class Console
    attr_reader :game, :difficulty_name

    def welcome
      output(:welcome)
      welcome_instructions
    end

    private

    def welcome_instructions
      case ask(:welcome_instruction).downcase
      when 'game' then new_game
      when 'stats' then output_statistics
      when 'exit' then exit
      else
        output(:spelling_error)
        welcome_instructions
      end
    end

    def new_game
      rules
      handle_difficulty
      @game = Codebreaker::Game.new(difficulty_name)
      game_round
    end

    def game_round
      while game.attempts.positive?
        user_answer = round_question(game.attempts)
        next hint if user_answer == 'hint'
        return win if game.equal_codes?(user_answer)
        round_message(user_answer)
      end
      lose
    end

    def handle_difficulty
      @difficulty_name = ask(:choose_difficulty).to_sym
      return if Game::DIFFICULTIES.key? @difficulty_name
      output(:spelling_error)
      handle_difficulty
    end

    def hint
      msg = game.hints.empty? ? :no_hint : game.take_a_hint!
      output(msg)
    end

    def round_message(user_answer)
      message = game.valid_answer?(user_answer) ? game.handle_guess(user_answer) : :invalid_number
      output(message)
    end

    def output(message)
      puts message.is_a?(Symbol) ? phrases[message] : message
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
      welcome_instructions
    end

    def round_question(attempts)
      ask("#{phrases[:round_question]}#{attempts}")
    end

    def win
      output(:win)
      Codebreaker::Storage.save_score(score_data) if dichotomy_question?(:save_score)
      dichotomy_question?(:new_game) ? new_game : output(:goodbye)
    end

    def lose
      output(phrases[:lose] << game.secret_code.join)
      dichotomy_question?(:new_game) ? new_game : output(:goodbye)
    end

    def difficulty_rules
      Game::DIFFICULTIES.each do |diff_name, params|
        output("#{diff_name}: #{params[:attempts]} attempts and #{params[:hints]} hints")
      end
    end

    def phrases
      @phrases ||= Codebreaker::Storage.load_file('phrases')
    end

    def statistics
      @statistics ||= Codebreaker::Storage.load_file('statistics')
    end

    def handle_statistics_for_output
      statistics.map do |record|
        "#{record[:name]} won the game on #{record[:difficulty]} level and still had #{record[:attempts]} attempts and #{record[:hints]} hints"
      end
    end

    def score_data
      name = ask(:username)
      { name: name, difficulty: @difficulty_name, attempts: game.attempts, hints: game.hints.size }
    end
  end

end
