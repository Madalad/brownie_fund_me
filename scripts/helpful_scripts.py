from brownie import network, accounts, MockV3Aggregator
import os
from web3 import Web3

FORKED_LOCAL_ENVIRONMENTS = ["mainnet-fork", "mainnet-fork-dev"]
LOCAL_BLOCKCHAIN_ENVIRONMENTS = ["development", "ganache-local"]
DECIMALS = 8
STARTING_PRICE = 200000000000


def get_account():
    if (
        network.show_active() in LOCAL_BLOCKCHAIN_ENVIRONMENTS
        or network.show_active() in FORKED_LOCAL_ENVIRONMENTS
    ):
        return accounts[0]
    else:
        return accounts.add(os.getenv("PRIVATE_KEY"))


def deploy_mocks():
    print(f"The active network is {network.show_active()}")
    print("Deploying mocks...")
    # check if mock has already been deployed
    if len(MockV3Aggregator) <= 0:
        MockV3Aggregator.deploy(
            DECIMALS, Web3.toWei(STARTING_PRICE, "ether"), {"from": get_account()},
        )
    price_feed_address = MockV3Aggregator[-1].address
    print("Mocks deployed!")
