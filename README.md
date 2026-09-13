# Universal Upgradeable Proxy Standard

A demonstration of ERC-1822 Upgradeable Smart Contracts

The goal is to have a concrete implementation of upgrading a smart
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

This shows that we have successfully upgraded the contract implementation.

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
