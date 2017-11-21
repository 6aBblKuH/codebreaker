class Console

  def message(val)
    puts val
  end

  def question(q)
    puts q
    gets.chomp
  end
end
