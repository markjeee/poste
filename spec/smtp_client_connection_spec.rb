require File.expand_path('../spec_helper', __FILE__)

describe "SMTP Client Connection" do
  describe "connect" do
    before(:all) do
      @config = Palmade::Poste::Config.parse(SPEC_POSTE_CONFIG_FILE)
      @init = Palmade::Poste.init!(@config)
      @smtp_server = @init.smtp_server
      @smtp_server.configure
    end

    # TODO: For implementation
  end
end
