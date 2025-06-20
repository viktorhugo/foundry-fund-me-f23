# exec make

-include .env

build:
	forge build;

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(SEPOLIA_RPC_URL) --broadcast --sender $(ADDRESS_SENDER) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv;

deploy-testnet-ganache:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(RPC_URL_GANACHE) --broadcast --account defaultKeyGanache --sender $(ADDRESS_SENDER_GANACHE) -vvvv

deploy-testnet-anvil:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL)  --broadcast -vvvv

.PHONY: all test clean deploy fund help install snapshot format anvil

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make fund [ARGS=...]\n    example: make fund ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.0.11 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@0.6.1 --no-commit && forge install foundry-rs/forge-std@v1.5.3 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url  $(RPC_URL) --private-key $(DEFAULT_ANVIL_KEY) --broadcast
NETWORK_ARGS_SENDER := --rpc-url  $(RPC_URL) --sender $(ADDRESS_SENDER) --verify --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS)

deploy-sender:
	@forge script script/DeployFundMe.s.sol:DeployFundMe $(NETWORK_ARGS_SENDER)

# For deploying Interactions.s.sol:FundFundMe as well as for Interactions.s.sol:WithdrawFundMe we have to include a sender's address `--sender <ADDRESS>`
SENDER_ADDRESS := <sender's address>

fund:
	@forge script script/Interactions.s.sol:FundFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)

withdraw:
	@forge script script/Interactions.s.sol:WithdrawFundMe --sender $(SENDER_ADDRESS) $(NETWORK_ARGS)