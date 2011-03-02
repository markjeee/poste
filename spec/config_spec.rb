require File.expand_path('../spec_helper', __FILE__)

describe "Config" do
  describe "parse" do
    before(:all) do
      @config = Palmade::Poste::Config.parse(SPEC_POSTE_CONFIG_FILE)
    end

    it "should parse sample config file" do
      @config.keys.should_not be_empty
    end

    it "should load working_path" do
      @config[:working_path].should == "spec/var/lib/poste"
    end

    it "should load tmp_path" do
      @config[:tmp_path].should == "tmp"
    end

    it "should load log_path" do
      @config[:log_path].should == "log"
    end

    it "should load mongo config" do
      @config[:mongo].should_not be_empty
      @config[:mongo][:host].should == "127.0.0.1"
    end

    after(:all) do

    end
  end
end
