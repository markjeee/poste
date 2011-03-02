require File.expand_path('../spec_helper', __FILE__)

describe "Init" do
  describe "init" do
    before(:all) do
      @config = Palmade::Poste::Config.parse(SPEC_POSTE_CONFIG_FILE)
      @init = Palmade::Poste.init!(@config)
      @smtp_server = @init.smtp_server
      @smtp_server.configure
    end

    it "init should set config properly" do
      @init.config.should_not be_nil
      @init.config.should be_an_instance_of(Palmade::Poste::Config)
      @init.config.should == @config
    end

    it "smtp_server should set config properly" do
      @smtp_server.config.should_not be_nil
      @smtp_server.config.should be_an_instance_of(Palmade::Poste::Config)
      @smtp_server.config.should == @config
    end

    after(:all) do

    end
  end
end
