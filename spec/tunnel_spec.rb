require 'pagoda-tunnel'

class Tun
  include Pagoda::Tunnel
end
describe Pagoda::Tunnel do


  it "does something" do
    Tun.new.something.should == true
  end

end