module EventMachine
  module Synchrony

    class ConnectionPool
      # Patch for Blather XMPP DSL
      #
      # #Query being a mehod registered in the global namespace of Blather,
      # it needs to be defined explicitly (vs in #method_missing) to be 
      # correctly called
      
      def query(*args, &blk)
        execute(false) do |conn|
          conn.send(:query, *args, &blk)
        end
      end
      
      def query_id(*args, &blk)
        execute(false) do |conn|
          conn.send(:query, *args, &blk)
          conn.send(:query, 'SELECT LAST_INSERT_ID() AS last_id;')
        end
      end
      
    end
  end
end