# pragma version 0.4.3
"""
@title Vault
@notice Holds ETH deposits per account. An owner can pause new deposits.
"""

owner: public(address)
balances: public(HashMap[address, uint256])
total_deposits: public(uint256)
paused: public(bool)


@deploy
def __init__():
    self.owner = msg.sender


@external
@payable
def deposit():
    assert not self.paused, "paused"
    assert msg.value > 0, "zero deposit"
    self.balances[msg.sender] += msg.value
    self.total_deposits += msg.value


@external
def withdraw(amount: uint256):
    assert self.balances[msg.sender] >= amount, "insufficient balance"
    self.balances[msg.sender] -= amount
    self.total_deposits -= amount
    send(msg.sender, amount)


@external
def set_paused(flag: bool):
    assert msg.sender == self.owner, "not owner"
    self.paused = flag


@external
def transfer_ownership(new_owner: address):
    assert msg.sender == self.owner, "not owner"
    assert new_owner != empty(address), "zero owner"
    self.owner = new_owner


@external
@view
def is_owner(account: address) -> bool:
    """
    @notice Whether `account` is the current owner.
    """
    return account == self.owner
