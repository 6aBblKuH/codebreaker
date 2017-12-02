module DataHadling
  PHRASES_PATH = 'lib/codebreaker/src/phrases.yml'.freeze
  STATISTICS_PATH = 'lib/codebreaker/src/statistics.yml'.freeze

  def statistics
    @stats ||= YAML.load_file(STATISTICS_PATH)
  end

  def handle_statistics_for_output
    statistics.map do |record|
      "#{record[:name]} won the game on #{record[:difficulty]} level and still had #{record[:attempts]} attempts and #{record[:hints]} hints"
    end
  end

  def save_score(data)
    File.new(STATISTICS_PATH, 'w+') unless File.exist?(STATISTICS_PATH)
    record = statistics || []
    File.write(STATISTICS_PATH, (record << data).to_yaml)
  end

end
