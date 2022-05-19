from brownie import Fund, accounts, network, config, MockV3Aggregator
import os
from web3 import Web3

variable_environment = ["development", "ganache-local"]


def deploy_fundme():
    # this function is to access the price feed address for ganache and rinkeby differently
    account = account_add()
    if network.show_active() not in variable_environment:
        # for rinkeby
        price_feed_address = config["networks"][network.show_active()][
            "eth_use_price_feed"
        ]

    else:
        # for local ganache
        # MockV3Aggregator another solidity contract (already developed and available on github)
        if len(MockV3Aggregator) <= 0:
            MockV3Aggregator.deploy(18, Web3.toWei(2000, "ether"), {"from": account})

        price_feed_address = MockV3Aggregator[-1].address

    # to verify on etherscan, use publish_source = True
    fundme_contract = Fund.deploy(
        price_feed_address,
        {"from": account},
        publish_source=config["networks"][network.show_active()]["verify"],
    )
    print(fundme_contract)


def account_add():
    # this function is to accessing the private key/ account
    # for local ganache chain
    if network.show_active() in variable_environment:
        return accounts[0]
    # for using own account
    # use scripts/deploy.py --network rinkeby for rinkeby network
    else:
        return accounts.add(os.getenv("private_key"))


def main():
    deploy_fundme()
