## Foundry

**Foundry is a blazing fast, portable and modular toolkit for Ethereum application development written in Rust.**

1. forge install smartcontractkit/chainlink-brownie-contracts --no-commit
2. forge test -vv
3. forge script script/DeployFundMe.s.sol
4. see more details from errors => forge test -vv
5. forge test -vvvv --match-test testVersionIsAccurate  --fork-url $SEPOLIA_RPC_URL
6. forge coverage --fork-url $SEPOLIA_RPC_URL => see how many code its testing

# Four Types unit test

1. ( Unit ): testing a specific part (function ) of our code
2. ( Integration ): testing how our code works with other parts of our code
3. ( Forked ): testing our code on a simulated real environment
4. ( Staging ): testing our code in real environment that is not prod
