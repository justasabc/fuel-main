module MCollective
  module Agent
    class Nailyfact<RPC::Agent
      metadata    :name       => "Naily Fact Agent",
          :description    => "Key/values in a text file",
          :author     => "Puppet Master Guy",
          :license    => "GPL",
          :version    => "Version 1",
          :url        => "www.naily.com",
          :timeout    => 10

      nailyfile = "/etc/naily.facts"

      def parse_facts(fname)
        begin
          if File.exist?(fname)
            kv_map = {}
            File.readlines(fname).each do |line|
              if line =~ /^(.+)=(.+)$/    
                @key = $1.strip;                 
                @val = $2.strip               
                kv_map.update({@key=>@val})
              end                      
            end                  
            return kv_map
          else
            f = File.open(fname,'w')
            f.close
            return {}
          end             
        rescue
          logger.warn("Could not access naily facts file. There was an error in nailyfacts.rb:parse_facts")
          return {}
        end
      end

      def write_facts(fname, facts)
        if not File.exists?(File.dirname(fname))
          Dir.mkdir(File.dirname(fname))
        end

        begin
          f = File.open(fname,"w+")
          facts.each do |k,v|
            f.puts("#{k} = #{v}")
          end
          f.close
          return true
        rescue
          return false
        end
      end

      action "get" do
        validate :key, String
        kv_map = parse_facts(nailyfile)
        if kv_map[request[:key]] != nil
          reply[:value] = kv_map[request[:key]]
        end
      end

      action "post" do
        validate :value, Hash

        kv_map = request[:value]

        if write_facts(nailyfile, kv_map)
          reply[:msg] = "Settings Updated!"
        else
          reply.fail! "Could not write file!"
        end
      end
    end
  end
end
