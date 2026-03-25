class WaTrialController < ApplicationController
  def index
    @data = []

    for s in 1..20 do
      @data.push({
        key: s
      })
    end

    0.upto(12) do |i|
      @data.push({
        key: i
      })
    end
  end
end
