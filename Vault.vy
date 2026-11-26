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


@internal
def _credit(account: address, amount: uint256):
    self.balances[account] += amount
    self.total_deposits += amount


@internal
def _debit(account: address, amount: uint256):
    balance: uint256 = self.balances[account]
    assert balance >= amount, "insufficient balance"
    self.balances[account] = balance - amount
    self.total_deposits -= amount


@external
@payable
def deposit():
    assert not self.paused, "paused"
    assert msg.value > 0, "zero deposit"
    self._credit(msg.sender, msg.value)


@external
def withdraw(amount: uint256):
    self._debit(msg.sender, amount)
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
