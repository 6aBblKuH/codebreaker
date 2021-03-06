require 'codebreaker'

RSpec.describe Codebreaker::Console do
  before do
    allow(subject).to receive(:output)
  end

  context '#welcome' do
    it 'calls output and welcome_instructions methods' do
      allow(subject).to receive(:welcome_instructions)
      expect(subject).to receive(:output)
      expect(subject).to receive(:welcome_instructions)
      subject.welcome
    end
  end

  context '#new_game' do
    before do
      allow(subject).to receive(:rules)
      allow(subject).to receive(:handle_difficulty)
      allow(subject).to receive(:game_round)
      subject.instance_variable_set(:@difficulty_name, :easy)
    end

    it 'calls rules, handle_difficulty and game_round methods' do
      expect(subject).to receive(:rules)
      expect(subject).to receive(:handle_difficulty)
      expect(subject).to receive(:game_round)
      subject.send(:new_game)
    end

    it 'creates instance variable with Game object' do
      expect { subject.send(:new_game) }.to change { subject.game }.to(Codebreaker::Game)
    end
  end

  context '#hint' do
    before do
      subject.instance_variable_set(:@game, Codebreaker::Game.new(:easy))
    end

    it 'outputs warning about unexisting hints' do
      subject.game.instance_variable_set(:@hints, [])
      expect(subject).to receive(:output).with(:no_hint)
      subject.send(:hint)
    end

    it 'calls method for getting hint' do
      allow(subject.game).to receive(:take_a_hint!)
      expect(subject.game).to receive(:take_a_hint!)
      subject.send(:hint)
    end
  end

  context '#round_message' do

    it 'calls game instance method  handle_guess ' do
      allow(subject.game).to receive(:valid_answer?).and_return(0)
      expect(subject.game).to receive(:handle_guess)
      subject.send(:round_message, '1234')
    end

    it 'outputs error message' do
      allow(subject.game).to receive(:valid_answer?)
      expect(subject).to receive(:output).with(:invalid_number)
      subject.send(:round_message, '1234')
    end
  end

  context '#rules' do
    it 'calls outputing rules info ' do
      expect(subject).to receive(:output).with(:rules)
      expect(subject).to receive(:difficulty_rules)
      subject.send(:rules)
    end
  end

  context '#dichotomy_question?' do
    it 'calls ask method' do
      allow(subject).to receive(:ask).and_return('test')
      expect(subject).to receive(:ask)
      subject.send(:dichotomy_question?, 'test')
    end

    it 'returns false when user dissagree' do
      allow(subject).to receive(:ask).and_return('no')
      expect(subject.send(:dichotomy_question?, 'test')).to be_falsey
    end

    it 'returns true when user agree' do
      allow(subject).to receive(:ask).and_return('yes')
      expect(subject.send(:dichotomy_question?, 'test')).to be_truthy
    end
  end
end
