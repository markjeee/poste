require File.expand_path('../spec_helper', __FILE__)

describe "SMTP Message" do
  describe "create" do
    before(:all) do
      @config = Palmade::Poste::Config.parse(SPEC_POSTE_CONFIG_FILE)
      @init = Palmade::Poste.init!(@config)
      @smtp_server = @init.smtp_server
      @smtp_server.configure

      @message = Palmade::Poste::MimeMessage.new
      @message.new_transaction!

      @message.set_sender("mark@simpleteq.com")

      @message.add_recipient("mark001@simpleteq.com")
      @message.add_recipient("mark002@simpleteq.com")
      @message.add_recipient("mark003@simpleteq.com")

      @message << "MESSAGE BODY"
    end

    it "should create a new transaction id" do
      @message.transaction_id.should_not be_nil
    end

    it "should set sender" do
      @message.sender.should == "mark@simpleteq.com"
    end

    it "should add recipients" do
      @message.recipients.size.should == 3
      @message.recipients.should include("mark001@simpleteq.com")
      @message.recipients.should_not include("mark004@simpleteq.com")
    end

    it "should write data" do
      @message.instance_eval do
        @data_wrtn.should > 0
      end
      @message.data.first.should == "MESSAGE BODY"
    end

    it "should store it to spool" do
      @message.store
    end
  end
end
