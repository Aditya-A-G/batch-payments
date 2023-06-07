.DEFAULT_GOAL := help

FORGE := forge
ANVIL := anvil

help: # Show this help
	@egrep -h '\s#\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: # Install dependencies
	@${FORGE} install

compile: # Compile contracts
	@${FORGE} compile

.PHONY: test
test: clean forge_test # Run tests

forge_test: # Run forge tests
	@${FORGE} test -vvv

test_with_gas: # Run tests and calculate average price
	@${FORGE} test -vvv --gas-report

slither: # Run slither
	@slither .

run_node:
	@${ANVIL}

deploy_localhost: # Deploy smart contracts to local blockchain node
	@${FORGE} script ./script/BatchPayment.s.sol:BatchPaymentScript --broadcast -vvvv --rpc-url http://127.0.0.1:8545

clean: # Remove old artifacts
	@${FORGE} clean
