package parameters

import 
(
	"time"
)

var VerticesAmount = 10;
var AdditionalEdgesAmount = 10; 	
var PackagesAmount = 10;
var PacketLifetime = 10;
var AdditionalReverseEdgesAmount = 10;

const SenderDelay = time.Duration(1) * time.Second
const RecipientDelay = time.Duration(1) * time.Second
const PackageDelay = time.Duration(1) * time.Second
const MessageDelay = time.Duration(1) * time.Second

