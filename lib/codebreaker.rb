# frozen_string_literal: true

require_relative 'codebreaker/version'
require 'yaml'
require_relative 'codebreaker/console'
require_relative 'codebreaker/storage'
require_relative 'codebreaker/game'

module Codebreaker
  Codebreaker::Console.new
end
