import sys, conf, json, datetime
from twisted.internet import reactor, protocol
from twisted.web.client import getPage
from twisted.python import log


class ProxyClientProtocol(protocol.Protocol):

	def connectionMade(self):
		self.transport.write(self.factory.data)
		self.transport.loseConnection()


class ProxyClientFactory(protocol.ClientFactory):
	protocol = ProxyClientProtocol

	def __init__(self, data):
		self.data = data

class ProxyHerdFactory(protocol.ServerFactory):

	def __init__(self, server):
		self.server = server
		#cache of all clientIDs with their latest updated locations
		self.cache = {}
		filename = server + "_" + str(datetime.datetime.now()) + ".log"
		log.startLogging(open(filename, 'w'))

	def startFactory(self):
		log.msg("starting factory")

	def stopFactory(self):
		log.msg("stopping factory")

class ProxyHerdProtocol(protocol.Protocol):

	def dataReceived(self, data):
		log.msg("received message: " + data)
		dataList = data.split()

		if dataList[0] == "IAMAT" and self.checkIAMAT(dataList[1:]):
			self.IAMAT(dataList[1:])
		elif dataList[0] == "AT" and self.checkAT(dataList):
			self.AT(dataList[1:], data)
		elif dataList[0] == "WHATSAT" and self.checkWHATSAT(dataList[1:]):
			self.WHATSAT(dataList[1:])
		else:
			log.msg("? " + data)
			self.transport.write("? " + data)


	def getLoc(self, latlng):
		d = 0
		for i in latlng[1:]:
			d += 1
			if i == '-' or i == '+':
				break
		lat = latlng[:d]
		lng = latlng[d:]
		return lat,lng

	def gpsCheck(self, latlng):
		lat, lng = self.getLoc(latlng)
		try:
			flat = float(lat)
			flng = float(lng)
			if flat > 90 or flat < -90 or flng > 180 or flng < -180:
				return False
			return True
		except ValueError:
			return False

	def getTimeDelta(self, time):
		delta = datetime.datetime.utcnow() - datetime.datetime.fromtimestamp(time)
		return "+" + str(delta.total_seconds())


	def IAMATPropagate(self, msg):
		neighbors = conf.NEIGHBORS[self.factory.server]
		for n in neighbors:
			log.msg("CONNECT_TCP: propagating from " + self.factory.server + " to " + n)
			reactor.connectTCP('localhost', conf.PORT_NUM[n], ProxyClientFactory(msg))


	def ATPropagate(self, msg, original):
		neighbors = conf.NEIGHBORS[self.factory.server]
		n1, n2 = neighbors[0], neighbors[1]
		# if n1 == original or n2 == original:
		if not n1 == original:
			log.msg("CONNECT_TCP: propagating from " + self.factory.server + " to " + n1)
			reactor.connectTCP('localhost', conf.PORT_NUM[n1], ProxyClientFactory(msg))
		elif not n2 == original:
			log.msg("CONNECT_TCP: propagating from " + self.factory.server + " to " + n2)
			reactor.connectTCP('localhost', conf.PORT_NUM[n2], ProxyClientFactory(msg))
		# else:
		# 	log.msg("all servers have been updated")


	def checkIAMAT(self, data):
		if len(data) != 3:
			log.err("IAMAT: should have 3 parameters: clientID, latlng, and time")
			return False
		if not self.gpsCheck(data[1]):
			log.err("IAMAT: not correctly formatted in ISO 6709")
			return False
		try:
			float(data[2])
			return True
		except ValueError:
			log.err("IAMAT: time is not in correct format")
			return False


	def checkAT(self, data):
		if len(data) != 6:
			log.err("AT: message should have 6 parameters")
			return False
		try:
			time_delta = float(data[2])
		except ValueError:
			log.error("AT: time delta is not in correct format")
			return False
		return self.checkIAMAT(data[3:])

	def checkWHATSAT(self, data):
		if len(data) != 3:
			log.err("WHATSAT: should have 3 parameters")
			return False
		if self.factory.cache.get(data[0], "") == "":
			log.err("WHATSAT: unknown client, cannot get location.  Perhaps cache hasn't been updated yet.  Please try with another server.")
			return False
		if int(data[1]) > 50:
			log.err("WHATSAT: radius must be at most 50 km")
			return False
		if (int(data[2])) > 20:
			log.err("WHATSAT: maximum of 20 items allowed per request")
			return False
		return True


	# IAMAT ID latlng time
	def IAMAT(self, data):
		
		clientID = data[0]
		latlng = data[1]
		time = data[2]
		latency = self.getTimeDelta(float(time))
		response = "AT " + self.factory.server + " " + latency + " " + clientID + " " + latlng + " " + time
		log.msg("response to client: " + response)
		self.transport.write(response)

		if self.factory.cache.get(clientID, "") == "":
			self.factory.cache[clientID] = (latlng, time)
			self.IAMATPropagate(response)
		else:
			latest = self.factory.cache[clientID][1]
			if float(latest) < float(time):
				self.factory.cache[clientID] = (latlng, time)
				self.IAMATPropagate(response)


	def AT(self, data, msg):

		# original = data[0]
		# clientID = data[2]
		# latlng = data[3]
		# time = data[4]

		# if self.factory.cache.get(clientID, "") == "":
		# 	self.factory.cache[clientID] = (latlng, float(time))
		# 	self.ATPropagate(msg, original)
		# else:
		# 	latest = self.factory.cache[clientID][1]
		# 	if latest < time:
		# 		self.factory.cache[clientID] = (latlng, float(time))
		# 		self.ATPropagate(msg, original)
		original = data[0]
		clientID = data[2]
		latlng = data[3]
		time = data[4]

		if self.factory.cache.get(clientID, "") == "":
			self.factory.cache[clientID] = (latlng, time)
			self.ATPropagate(msg, original)
		else:
			latest = self.factory.cache[clientID][1]
			log.msg("comparing latest: " + latest + " with stored: " + time)
			if latest == time:
				log.msg("AT: " + original + " latest location already stored")
				return
			if float(latest) < float(time):
				self.factory.cache[clientID] = (latlng, time)
				self.ATPropagate(msg, original)


	# WHATSAT ID radius(in km) upperboundnum
	def WHATSAT(self, data):
		requestURL = self.constructRequest(data)
		log.msg("requesting from google places API: " + requestURL)
		response = getPage(requestURL)
		response.addCallback(self.filterResponse, data[0], int(data[2]))
		response.addErrback(self.callbackError)

	def constructRequest(self, data):
		key = "key=" + conf.API_KEY
		res = self.getLoc(self.factory.cache[data[0]][0])
		print "result: " + str(res)
		lat,lng = res
		print "lat and long" + lat + lng
		loc = "location=" + lat +  "," + lng
		rad = "radius=" + str(int(data[1])*1000)
		request = conf.API_ENDPOINT + loc + "&" + rad + "&" + key
		return request


	def filterResponse(self, response, clientID, limit):
		data = json.loads(response)
		results = data["results"][:limit]
		data["results"] = results
		time = self.factory.cache[clientID][1]
		latency = self.getTimeDelta(float(time))
		construct_msg = "AT " + self.factory.server + " " + latency + " " + clientID + " " + self.factory.cache[clientID][0] + " " + time
		result = construct_msg + "\n" + json.dumps(data, indent = 4) + "\n\n"
		# log.msg("fileredResponse sent: " + result)
		self.transport.write(result)

	def callbackError(self, error):
		log.err("api request error: " + str(error))

def main():

	if len(sys.argv) != 2:
		print("requires exactly one argument")
		exit(1)

	server = sys.argv[1]
	portnum = conf.PORT_NUM.get(server, 0)
	if portnum == 0:
		print("Possible servers: Alford, Ball, Hamilton, Holiday, Welsh")
		exit(1)

	print("portnum is: "+str(portnum))

	factory = ProxyHerdFactory(server)
	factory.protocol = ProxyHerdProtocol
	reactor.listenTCP(portnum, factory)
	reactor.run()

if __name__ == '__main__':
	main()
