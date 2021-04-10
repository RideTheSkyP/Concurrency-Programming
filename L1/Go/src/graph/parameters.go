package graph

import 
(
	"time"
)

const VerticesAmount = 10;
const AdditionalEdgesCount = 10;
const PackagesAmount = 5;

const SenderDelay = time.Duration(1) * time.Second
const RecipientDelay = time.Duration(1) * time.Second
const PackageDelay = time.Duration(1) * time.Second  
const MessageDelay = time.Duration(1) * time.Second  
