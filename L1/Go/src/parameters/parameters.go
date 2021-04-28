package parameters

import 
(
	"time"
)

var VerticesAmount = 10;
var AdditionalEdgesCount = 5; 	
var PackagesAmount = 5;
var PacketLifetime = 5;

const SenderDelay = time.Duration(1) * time.Second
const RecipientDelay = time.Duration(1) * time.Second
const PackageDelay = time.Duration(1) * time.Second  
const MessageDelay = time.Duration(1) * time.Second 

