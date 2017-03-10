# Google Places API key
API_KEY="AIzaSyDorq1I4FfcDLLbcr74zIBSLj2N8bgTUNY"
API_ENDPOINT="https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

# TCP port numbers for server instances
# Please use the port numbers allocated by the TA.
PORT_NUM = {
    'Alford': 12560,
    'Ball': 12561,
    'Hamilton': 12562,
    'Holiday': 12563,
    'Welsh': 12564
}

NEIGHBORS = {
	'Alford': ['Hamilton', 'Welsh'],
	'Ball': ['Holiday', 'Welsh'],
	'Hamilton': ['Holiday', 'Alford'],
	'Welsh': ['Alford', 'Ball'],
	'Holiday': ['Ball', 'Hamilton']
}