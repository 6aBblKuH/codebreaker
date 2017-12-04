# frozen_string_literal: true

require_relative 'codebreaker/version'
require 'yaml'
require 'pry'
require_relative 'codebreaker/console'
require_relative 'codebreaker/loader'
require_relative 'codebreaker/game'

module Codebreaker
  Game.new
end
