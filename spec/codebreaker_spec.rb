# frozen_string_literal: true

RSpec.describe Game do
  context '#make_secret_code' do
    before do
      @secret_code = subject.send(:make_secret_code)
    end

    it 'return secret code' do
      expect(@secret_code).to be_kind_of(Array)
    end

    it 'has 4 digit' do
      expect(@secret_code.size).to eq(4)
    end

    it 'has only digits between 1 and 6' do
      expect(@secret_code.join =~ /^[1-6]{4}$/).to be_truthy
    end
  end

  context '#compare_codes' do
    before do
      subject.instance_variable_set(:@secret_code, [1, 2, 3, 4])
    end

    it 'has to return false' do
      expect(subject.compare_codes).to be false
    end

    it 'has to return true' do
      subject.instance_variable_set(:@user_code, [1, 2, 3, 4])
      expect(subject.compare_codes).to be true
    end
  end

  context '#take_a_hint!' do
    before do
      subject.instance_variable_set(:@hints, [1, 2, 3, 4])
      subject.instance_variable_set(:@hints_count, 2)
    end

    it 'return last number from hints array' do
      expected_hint = subject.instance_variable_get(:@hints).last
      expect(subject.send(:take_a_hint!)).to eq(expected_hint)
    end

    it 'take one number as hint and remove it from array' do
      expect { subject.send(:take_a_hint!) }.to change { subject.instance_variable_get(:@hints).size }.by(-1)
    end

    it 'decrement hints count by one' do
      expect { subject.send(:take_a_hint!) }.to change { subject.instance_variable_get(:@hints_count) }.by(-1)
    end
  end

  context '#hint' do
    it 'tells about missing hints' do
      subject.instance_variable_set(:@hints_count, 0)
      expect { subject.send(:hint) }.to output("Hints are over\n").to_stdout
    end

    it 'does one hint' do
      subject.instance_variable_set(:@hints, [1, 2, 3, 4])
      subject.instance_variable_set(:@hints_count, 2)
      expect { subject.send(:hint) }.to output("4\n").to_stdout
    end
  end

  context '#handle_answer' do
    it 'calls a hint' do
      subject.instance_variable_set(:@user_answer, 'hint')
      allow(subject).to receive(:hint)
      expect(subject).to receive(:hint)
      subject.send(:handle_answer)
    end

    it 'calls validate method' do
      subject.instance_variable_set(:@user_answer, 'test')
      expect(subject).to receive(:validate_answer)
      subject.send(:handle_answer)
    end

    it 'handles correct number' do
      subject.instance_variable_set(:@user_answer, '1234')
      expect(subject).to receive(:handle_code)
      subject.send(:handle_answer)
    end
  end

  context '#validate_answer' do
    it 'tells about input error' do
      expect { subject.send(:validate_answer) }.to output("Put 4-digital number\n").to_stdout
    end

    it 'returns true' do
      subject.instance_variable_set(:@user_answer, '1234')
      expect(subject.send(:validate_answer)).to be true
    end
  end

  context '#setup_the_difficulty' do
    it 'setup easy level of difficulty' do
      subject.instance_variable_set(:@difficulty, Game::DIFFICULTY[:easy])
      subject.send(:setup_the_difficulty)
      expect(subject.instance_variable_get(:@attempts_count)).to eq(Game::DIFFICULTY.dig(:easy, :attempts))
      expect(subject.instance_variable_get(:@hints_count)).to eq(Game::DIFFICULTY.dig(:easy, :hints))
    end

    it 'setup medium level of difficulty' do
      subject.instance_variable_set(:@difficulty, Game::DIFFICULTY[:medium])
      subject.send(:setup_the_difficulty)
      expect(subject.instance_variable_get(:@attempts_count)).to eq(15)
      expect(subject.instance_variable_get(:@hints_count)).to eq(2)
    end

    it 'setup hard level of difficulty' do
      subject.instance_variable_set(:@difficulty, Game::DIFFICULTY[:hard])
      subject.send(:setup_the_difficulty)
      expect(subject.instance_variable_get(:@attempts_count)).to eq(10)
      expect(subject.instance_variable_get(:@hints_count)).to eq(1)
    end
  end

  context '#difficulty' do
    it "tells about spelling error and calls itself again" do
      allow(subject).to receive(:choose_the_difficulty)
      expect(subject).to receive(:choose_the_difficulty)
      subject.send(:handle_difficulty, 'test')
    end

    it "calls setuping method with easy lvl" do
      allow(subject).to receive(:setup_the_difficulty)
      expect(subject).to receive(:setup_the_difficulty)
      subject.send(:handle_difficulty, 'easy')
    end

    it "calls setuping method with medium lvl" do
      allow(subject).to receive(:setup_the_difficulty)
      expect(subject).to receive(:setup_the_difficulty)
      subject.send(:handle_difficulty, 'medium')
    end

    it "calls setuping method with hard lvl" do
      allow(subject).to receive(:setup_the_difficulty)
      expect(subject).to receive(:setup_the_difficulty)
      subject.send(:handle_difficulty, 'hard')
    end
  end
end

RSpec.describe Console do
end
