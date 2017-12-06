# frozen_string_literal: true

RSpec.describe Game do
  subject { Game.new(:easy) }

  context 'instance variables after creating Game object' do
    context 'secret_code' do
      let(:secret_code) { subject.secret_code }

      it 'return secret code' do
        expect(secret_code).to be_kind_of(Array)
      end

      it 'has 4 digit' do
        expect(secret_code.size).to eq(4)
      end

      it 'has only digits between 1 and 6' do
        expect(secret_code.join).to match(/^[1-6]{4}$/)
      end
    end

    context 'attempts' do
      it "sets easy lvl for attempts" do
        expect(subject.attempts).to eq(Game::DIFFICULTIES.dig(:easy, :attempts))
      end

      it "sets medium lvl for attempts" do
        expect(Game.new(:medium).attempts).to eq(Game::DIFFICULTIES.dig(:medium, :attempts))
      end

      it "sets hard lvl for attempts" do
        expect(Game.new(:hard).attempts).to eq(Game::DIFFICULTIES.dig(:hard, :attempts))
      end
    end

    context 'hints' do
      it "sets easy lvl for hints" do
        expect(subject.hints.size).to eq(Game::DIFFICULTIES.dig(:easy, :hints))
      end

      it "sets medium lvl for hints" do
        expect(Game.new(:medium).hints.size).to eq(Game::DIFFICULTIES.dig(:medium, :hints))
      end

      it "sets hard lvl for hints" do
        expect(Game.new(:hard).hints.size).to eq(Game::DIFFICULTIES.dig(:hard, :hints))
      end
    end
  end

  context '#equal_codes?' do
    before { subject.instance_variable_set(:@secret_code, [1, 2, 3, 4]) }

    it 'has to return false' do
      expect(subject.equal_codes?('1111')).to be false
    end

    it 'has to return true' do
      expect(subject.equal_codes?('1234')).to be true
    end
  end

  context '#hints' do
    it "return array of hints" do
      expect(subject.hints).to be_kind_of Array
      expect(subject.hints.size).to eq(Game::DIFFICULTIES.dig(:easy, :hints))
    end
  end

  context '#take_a_hint!' do
    it "takes one hint" do
      expect { subject.take_a_hint! }.to change { subject.hints.size }.by(-1)
    end

    it 'return last number from hints array' do
      expected_hint = subject.hints.last
      expect(subject.take_a_hint!).to eq(expected_hint)
    end
  end

  context '#valid_answer?' do
    it 'tells about input error' do
      expect(subject.valid_answer?('test')).to be_falsey
    end

    it 'returns true' do
      expect(subject.valid_answer?('1234')).to be_truthy
    end
  end

  context '#handle_guess' do
    it "creates user code array" do
      subject.instance_variable_set(:@secret_code, [6, 6, 6, 6])
      expect { subject.handle_guess('1234') }.to change { subject.user_code }.to([1, 2, 3, 4])
    end

    it "calls handle_numbers" do
      expect(subject).to receive(:handle_numbers)
      subject.instance_variable_set(:@round_result, '')
      subject.handle_guess('1234')
    end

    it "decrements quantity of attempts" do
      expect { subject.handle_guess('1234') }.to change { subject.attempts }.by(-1)
    end

    it "tells something if result is empty" do
      subject.instance_variable_set(:@secret_code, [1, 1, 1, 1])
      expect(subject.handle_guess('2222')).to eq('No matches')
    end

    it "tells something if result is not empty" do
      allow(subject).to receive(:handle_numbers)
      subject.instance_variable_set(:@round_result, 'test')
      expect(subject.handle_guess('2221')).to eq('test')
    end
  end

  context '#handle_numbers' do
    it "calls check_numbers_for_correct_position method" do
      subject.user_code = [2, 2, 2, 2]
      allow(subject).to receive(:check_numbers_for_correct_position).and_return([1, 1, 1, 1])
      expect(subject).to receive(:check_numbers_for_correct_position)
      subject.send(:handle_numbers)
    end

    context 'assigns round_result to' do
      it "-" do
        subject.user_code = [2, 2, 2, 4]
        allow(subject).to receive(:check_numbers_for_correct_position).and_return([1, 4, 1, 1])
        expect { subject.send(:handle_numbers) }.to change { subject.instance_variable_get(:@round_result) }.to('-')
      end

      it "--" do
        subject.user_code = [2, 2, 2, 4]
        allow(subject).to receive(:check_numbers_for_correct_position).and_return([1, 4, 2, 1])
        expect { subject.send(:handle_numbers) }.to change { subject.instance_variable_get(:@round_result) }.to('--')
      end

      it "---" do
        subject.user_code = [1, 1, 2, 4]
        allow(subject).to receive(:check_numbers_for_correct_position).and_return([1, 4, 1, 1])
        expect { subject.send(:handle_numbers) }.to change { subject.instance_variable_get(:@round_result) }.to('---')
      end

      it "----" do
        subject.user_code = [2, 3, 2, 4]
        allow(subject).to receive(:check_numbers_for_correct_position).and_return([3, 2, 4, 2])
        expect { subject.send(:handle_numbers) }.to change { subject.instance_variable_get(:@round_result) }.to('----')
      end

      it "+-" do
        subject.user_code = [1, 2, 3, 6]
        subject.instance_variable_set(:@secret_code, [1, 3, 5, 3])
        expect { subject.send(:handle_numbers) }.to change { subject.instance_variable_get(:@round_result) }.to('+-')
      end

      it "+---" do
        subject.user_code = [1, 2, 3, 6]
        subject.instance_variable_set(:@secret_code, [1, 3, 6, 2])
        expect { subject.send(:handle_numbers) }.to change { subject.instance_variable_get(:@round_result) }.to('+---')
      end

      it "++-" do
        subject.user_code = [1, 2, 3, 6]
        subject.instance_variable_set(:@secret_code, [1, 3, 5, 6])
        expect { subject.send(:handle_numbers) }.to change { subject.instance_variable_get(:@round_result) }.to('++-')
      end

      it "++--" do
        subject.user_code = [1, 2, 3, 6]
        subject.instance_variable_set(:@secret_code, [1, 3, 2, 6])
        expect { subject.send(:handle_numbers) }.to change { subject.instance_variable_get(:@round_result) }.to('++--')
      end

      it "+++" do
        subject.user_code = [1, 2, 3, 6]
        subject.instance_variable_set(:@secret_code, [1, 3, 3, 6])
        expect { subject.send(:handle_numbers) }.to change { subject.instance_variable_get(:@round_result) }.to('+++')
      end
    end

  end

  context '#check_numbers_for_correct_position' do
    before { subject.instance_variable_set(:@secret_code, [1, 2, 1, 3]) }

    it "returns same array if noone element didn`t match" do
      subject.instance_variable_set(:@user_code, [5, 5, 5, 5])
      expect(subject.send(:check_numbers_for_correct_position)).to eq([1, 2, 1, 3])
    end

    context 'change user_code array and returns array where' do
      it "one guessed number is nil" do
        subject.instance_variable_set(:@user_code, [1, 5, 5, 5])
        expect(subject.send(:check_numbers_for_correct_position)).to eq([nil, 2, 1, 3])
        expect(subject.user_code).to eq([nil, 5, 5, 5])
      end

      it "two guessed numbers are nil" do
        subject.instance_variable_set(:@user_code, [1, 3, 5, 3])
        expect(subject.send(:check_numbers_for_correct_position)).to eq([nil, 2, 1, nil])
        expect(subject.user_code).to eq([nil, 3, 5, nil])
      end

      it "three guessed numbers are nil" do
        subject.instance_variable_set(:@user_code, [1, 2, 1, 5])
        expect(subject.send(:check_numbers_for_correct_position)).to eq([nil, nil, nil, 3])
        expect(subject.user_code).to eq([nil, nil, nil, 5])
      end
    end
  end
end

# RSpec.describe Console do

# end
