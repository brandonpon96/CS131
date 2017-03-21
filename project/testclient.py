
# Copyright (c) Twisted Matrix Laboratories.
# See LICENSE for details.


"""
An example client. Run simpleserv.py first before running this.
"""
from __future__ import print_function

from twisted.internet import reactor, protocol


# a client protocol

class EchoClient(protocol.Protocol):
    """Once connected, send a message, then print the result."""
    
    def connectionMade(self):
          # self.transport.write("WHATSAT kiwi.cs.ucla.edu 10 2")
          self.transport.write("IAMAT kiwi.cs.ucla.edu +40.068930-74.445127 1479423884.392014450")
          # self.transport.write("IAMAT kiwi.cs.ucla.edu +25.105930+121.597127 1479433884.392014450")
    
    def dataReceived(self, data):
        "As soon as any data is received, write it back."
        print(data)
        self.transport.loseConnection()
    
    def connectionLost(self, reason):
        print("connection lost")

class EchoFactory(protocol.ClientFactory):
    protocol = EchoClient

    def clientConnectionFailed(self, connector, reason):
    	print("Connection failed - goodbye!")
    	reactor.stop()
    
    def clientConnectionLost(self, connector, reason):
        print("Connection lost - goodbye!")
        reactor.stop()


# this connects the protocol to a server running on port 8000
def main():
    f = EchoFactory()
    reactor.connectTCP("localhost", 12560, f)
    reactor.run()

# this only runs if the module was *not* imported
if __name__ == '__main__':
    main()