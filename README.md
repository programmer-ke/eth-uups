# Universal Upgradeable Proxy Standard

A demonstration of EIP-1822 Upgradeable Smart Contracts

The goal is to have a concrete example of upgrading a smart
contract using the Universal Upgradeable Proxy Standard.

## How it works

In the UUPS, we have a proxy contract, which holds the state of the
contract and an implementation contract that contains the upgradeable
logic.

Here, the proxy contract is called `Proxy` and the v1 implementation
contract is called `BoxV1`.

### Step 1: Deploy V1

This is done using the [DeployBox](script/DeployBox.s.sol) script.

- In a separate terminal, start the local chain using `make anvil`.
- To deploy v1, run `make deploy`

This first deploys `BoxV1` as the implementation contract then
deploys `Proxy` with `BoxV1` address as the implementation.

V1's version method returns 1, so calling `version()` on the proxy
contract should return 1.

- Run `make version` and it should return 1.

We have an internal attribute `number` that is stored in the Proxy.
We can get its value using `getNumber()`. However in V1 we cannot set
its value.

- Run `make getNumber`, which should return 0 as the default.
- Run `make setNumber NUM=123` which should revert because we lack a
  `setNumber` method.

### Step 2: Deploy V2

This is done using the [UpgradeBox](script/UpgradeBox.s.sol) script.

The BoxV2 implementation has a `setNumber` method that we can use
to update the number attribute.

- Run `make upgrade`. This will deploy BoxV2 and upgrade the proxy
  implementation to it.
  
- Run `make version`. It should now return 2.

We should now be able to update the internal number attribute in the
proxy. 

- Run `make setNumber NUM=123`. It should successfully make the
  transation.
- `make getNumber` should now return 123.

This shows that we have successfully upgraded the contract
implementation.

## Related Topics

### EIP-1967

The `Proxy` contract is an implementation of an EIP-1967 contract.

The EIP-1967 proposal introduced standardized storage slots for more
reliable logic upgrades and to enable development of third party tools
that deal with proxy contracts in a uniform manner

- A special slot where the address of the logic contract is stored
- Where a [beacon contract][beacon] is used instead, a special slot
  for its address.
- A special slot for the address of the admin who's allowed to
  upgrade the logic contract address.
  
[beacon]: https://rareskills.io/post/beacon-proxy

These slots are large pseudorandom slots that are unlikely to collide
with the low-index storage slots the compiler allocates for the
implementation contract's state variables.

### Delegatecall

When a contract receives a call to a non-existent function, a special
function called `fallback` will be executed. In UUPS, a proxy
contract does not define methods of its own, it only acts as data
storage and all methods are supposed to be defined in implementation
contracts.

The `delegatecall` instruction allows a contract to execute the
bytecode of another contract within its own context. Therefore, when a
method call is made on the proxy, its `fallback` function uses
`delegatecall` to execute the relevant method in the implementation
contract within the proxy's own context. Therefore, any state
variables defined in the implementation contract and are modified by
its code in reality are modified in the proxy itself.

State variables in the implementation contract can be thought of as
placeholders for the actual storage slots that are modified in the
proxy contract, and should not be re-ordered in upgrades otherwise
there'll be corruption of state. New state variables should be defined
after existing ones in order.

### Initialization

Because implementation contracts should work on the Proxy's storage
and not on their own, Any necessary initialization needed for contract
state needs to happen outside their constructors.

A method called `initializer` is defined on the implementation
contracts so that it can be called from the proxy for initialization
work, in our case, setting the contract's owner.

We need to prevent `initializer` from being executed directly on the
implementation contracts themselves to allow an attacker to set
themselves as owners on the implementation contract. We do this by
calling `_disableInitializers` in the implementation contracts. This
will prevent any method with the `initializer` modifier from being
executed directly on the implementation contract.

When deploying the Proxy, we encode the implementation's `initialize`
method and pass it in its constructor. This ensures that the proxy is
deployed, its implementation set and the constructor called in one
transaction, preventing a malicious actor from front-running the
initialization.

Once `initialize` has been called, the `initializer` modifier will
prevent it from being called again on the proxy.

### Upgrading the Implementation Contract

To upgrade the implementation contract of a Proxy, we call the
`upgradeToAndCall` method passing in the address of the new
implementation and encoded functionality to call if necessary.

This will in turn call the `_authorizeUpgrade` method defined in the
implementation which can do any necessary checks to determine if the
upgrade is authorized. In our case, we using the `onlyOwner` modifier
to check that the caller is the owner set on the proxy.

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```


### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
