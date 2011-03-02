require File.expand_path('../spec_helper', __FILE__)

=begin
<<< 220 poste SMTP Server
>>> EHLO localhost.localdomain
<<< 250-Ok poste SMTP Server
<<< 250-NO-SOLICITING
<<< 250 SIZE 20971520
>>> MAIL FROM:<mark@mark-desktop.markjeee.com>
<<< 250 Ok
>>> RCPT TO:<mark@simpleteq.com>
<<< 250 Ok
>>> DATA
<<< 354 Send it
>>> Date: Fri, 28 Jan 2011 13:58:03 +0800
>>> From: mark@mark-desktop.markjeee.com
>>> To: mark@simpleteq.com
>>> Message-ID: <4d425aeba4bc4_78e446e1dca2478c@mark-desktop.mail>
>>> Subject: Hello World
>>> Mime-Version: 1.0
>>> Content-Type: text/plain;
>>>  charset=UTF-8
>>> Content-Transfer-Encoding: 7bit
>>>
>>> It's a rainy friday morning today. Cold day indeed
>>> .
<<< 250 Message accepted
>>> QUIT
<<< 221 Ok
=end

describe "Mail", :mail => true do
  describe "deliver" do
    before(:all) do
      @config = Palmade::Poste::Config.parse(SPEC_POSTE_CONFIG_FILE)
      @init = Palmade::Poste.init!(@config)

      @mail = Mail.new do
        to [ 'mark@simpleteq.com', 'mark@caresharing.eu' ]
        cc 'mark@etroduce.com'
        from 'mark@mark-desktop.markjeee.com'
        subject 'Hello World'
        body 'It\'s a rainy friday morning today. Cold day indeed'
      end

      @mail.delivery_method :smtp, :port => 2525
    end

    it "should deliver" do
      10.times { @mail.deliver! }
    end

    after(:all) do

    end
  end
end
