require "yaml"

class Console
  PhrasesPath = 'lib/codebreaker/src/phrases.yml'

  def initialize
    @phrases = YAML.load_file(PhrasesPath)
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
    @phrases[:difficulty].each do|diff, descr|
      message("#{diff}: #{descr}")
    end
  end

  def win
    message @phrases[:win]
  end

  def loose(secret_code)
    message @phrases[:loose] << secret_code.join
  end
end
