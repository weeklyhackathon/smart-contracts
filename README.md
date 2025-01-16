# Weekly Hackathon Voting Smart Contracts

Every week there is a number of project submissions, and they have an id.
A separate process gives each user a number of votes, and they can allocate
them to projects. This voting allocation is enforced using a signature that
the separate process creates.

## Setup

Create a .env.development and add the following:

```
BASE_RPC_URL=https://mainnet.base.org
MNEMONIC=test test test test test test test test test test test junk
```

## Usage 

```
npm install
APP_ENV=development npx hardhat compile
```

