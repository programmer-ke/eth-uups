-include .env

.PHONY: all test clean deploy version help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
DEFAULT_ANVIL_ADDRESS := 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266

BOXV1_ADDRESS := 0x5fbdb2315678afecb367f032d93f642f64180aa3

PROXY_ADDRESS := 0xe7f1725e7734ce288f8367e1bb143e90bb3f0512

help:
	@echo "Usage:"
	@echo "  make deploy [ARGS=...]\n    example: make deploy ARGS=\"--network sepolia\""
	@echo ""
	@echo "  make upgrade [ARGS=...]\n    example: make upgrade ARGS=\"--network sepolia\""

all: clean remove install update build

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install

# Update Dependencies
update:; forge update

build:; forge build

test :; forge test

snapshot :; forge snapshot

format :; forge fmt

anvil :; anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1

NETWORK_ARGS := --rpc-url http://localhost:8545 --private-key $(DEFAULT_ANVIL_KEY)

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployBox.s.sol:DeployBox $(NETWORK_ARGS)  --broadcast

version :; cast call ${PROXY_ADDRESS} "version()" $(NETWORK_ARGS)

getNumber :; cast --to-base `cast call ${PROXY_ADDRESS} "getNumber()" $(NETWORK_ARGS)` dec

setNumber :; cast send ${PROXY_ADDRESS} "setNumber(uint256)" $(NUM) $(NETWORK_ARGS)

upgrade:
	@forge script script/UpgradeBox.s.sol:UpgradeBox $(NETWORK_ARGS)  --broadcast
