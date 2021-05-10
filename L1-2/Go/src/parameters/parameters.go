package parameters

import 
(
	"time"
)

var VerticesAmount = 20;
var AdditionalEdgesAmount = 10; 	
var PackagesAmount = 20;
var PacketLifetime = 20;
var AdditionalReverseEdgesAmount = 10;

const SenderDelay = time.Duration(1) * time.Second
const RecipientDelay = time.Duration(1) * time.Second
const PackageDelay = time.Duration(1) * time.Second
const MessageDelay = time.Duration(1) * time.Second
const PoacherDelay = time.Duration(5) * time.Second
