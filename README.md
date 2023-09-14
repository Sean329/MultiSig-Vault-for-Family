# MultiSig Vault for Family

This is a Goerli copy of a simple but practical version of a Multi-Sig vault that my family (myWife and mySelf) are using to send outgoing payments on Mainnet. Both people must sign to execute transactions so neigher of us can move the money without the other's consent. We both are Smart Contract advocators so we CODIFY our daily decision making processes --- this one being one of the examples.

This Goerli copy is for the demo purposes for any Web3 job application if a demo is required.

This Multi-Sig vault works with both ETH and ERC20 payments, coded with DeFi security practice (prevent reentry) as well as gas optimization tricks.

I also added a *Dead Man's Switch* functionality to the contract so that in the situation of:
1. One of us is dead or doesn't care about this vault no more ------ the other one can withdraw the money after a 52 weeks cool down period
2. Both of us are dead for over a year ------ the kid who inherited our PKs can withdraw the money

That being said, LONG LIVE myWife and mySelf plz!!


```shell
npm init
npm i dotenv
npm i -D hardhat
npx hardhat

touch .env // add your personal PKs and APIs and save, import it into hardhat config, and maybe add customized networks in the config
```
