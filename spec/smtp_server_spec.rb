require File.expand_path('../spec_helper', __FILE__)

context "SMTP Server" do
  describe "configure" do
    before(:all) do
      @config = Palmade::Poste::Config.parse(SPEC_POSTE_CONFIG_FILE)
      @init = Palmade::Poste.init!(@config)
      @smtp_server = @init.smtp_server
      @smtp_server.configure
    end

    it "should parse the listen config" do
      @smtp_server.listen.should_not be_empty
    end

    it "should have one entry" do
      @smtp_server.listen.size.should == 2
    end

    it "should parse properly" do
      @smtp_server.listen.first.should == "127.0.0.1:2525"
    end

    after(:all) do

    end
  end
end
