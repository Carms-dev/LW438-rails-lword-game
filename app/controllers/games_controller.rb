require 'json'
require 'open-uri'

class GamesController < ApplicationController
    def new
        @letters = []
        10.times do
            @letters << ('A'..'Z').to_a.sample
        end
        cookies[:score] = 0 if cookies[:score].nil?

        @score = cookies[:score]
    end

    def score
        @letters = params[:letters]
        @word = params[:word]
        
        if !letter_check?(@letters, @word)
            @scenario = 1;
        elsif !valid_check?(@word)
            @scenario = 2;
        else
            @scenario = 3;
            cookies[:score] = cookies[:score].to_i + @word.length**2
        end
        @score = cookies[:score]
    end

    def reset
        cookies[:score] = 0
        redirect_to new_path
    end
    
    private
    
    def letter_check?(letters, word)
        l_hash = {}
        w_hash = {}
        letters.downcase.chars.each {|l| l_hash[l] ? l_hash[l] += 1 : l_hash[l] = 1}
        word.downcase.chars.each {|l| w_hash[l] ? w_hash[l] += 1 : w_hash[l] = 1}

        return w_hash.all? {|k, v| l_hash[k] && l_hash[k] >= v}
    end
    
    def valid_check?(word)
        url = "https://wagon-dictionary.herokuapp.com/#{@word}"
    
        result_serialized = open(url).read
        result = JSON.parse(result_serialized)
    
        return result["found"]
    end
end
