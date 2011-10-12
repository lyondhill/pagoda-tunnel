
require 'pagoda-tunnel'

describe Pagoda::Tunnel do

  it "can create a connection" do
    tunnel = Pagoda::Tunnel.new(nil,nil,nil,nil,nil)
  end

  it "cannot find an open port" do
    tunnel = Pagoda::Tunnel.new(nil,nil,nil,nil,nil)
    tunnel.port_available?("0.0.0.0", 3309).should == true
  end

  it "finds an open port" do
    sock = TCPServer.new("0.0.0.0", 40000)
    tunnel = Pagoda::Tunnel.new(nil,nil,nil,nil,nil)
    tunnel.port_available?("0.0.0.0", 40000).should == false
    sock.close
  end

  it "searches until it finds an available port" do
    tunnel = Pagoda::Tunnel.new(nil,nil,nil,nil,nil)
    tunnel.should_receive(:port_available?).with("0.0.0.0", 40000).and_return false
    tunnel.should_receive(:port_available?).with("0.0.0.0", 40001).and_return false
    tunnel.should_receive(:port_available?).with("0.0.0.0", 40002).and_return false
    tunnel.should_receive(:port_available?).with("0.0.0.0", 40003).and_return true
    STDOUT.stub(:puts)
    tunnel.next_available_port(40000).should == 40003
  end

  it "needs more testing"
  
end