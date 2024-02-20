## Get Started 
* You need to understand how to use Foundry forge
* download or clone the repo
* run ```forge test ``` for testing
* convert the env.local file to .env and enter the requirements, you can get the RPC URL from Alchemy
* I still have a failed test in function ```testMultipleBuy``` in the ```attemptSell``` function but other test passed successfully
  
### About 
The contract is a tax token contract, where tax is converted to ETH and sent to the Marketing wallet. 

it is still in progress since I am trying to refactor it to fit the latest solidity version with custom error, and implement openzeppelin v5 into it.