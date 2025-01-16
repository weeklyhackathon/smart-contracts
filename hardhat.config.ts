import type { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox-viem";
import { config as dotenvConfig } from "dotenv";
import { resolve as resolvePath } from "path";
import { env } from "./lib/common";

const TEST_MNEMONIC = "test test test test test test test test test test test junk";

[
  `.env.${process.env.APP_ENV}.contracts`,
  `.env.${process.env.APP_ENV}`
]
  .forEach((dotenvConfigPath) => {
    const path = resolvePath(__dirname, dotenvConfigPath);
    dotenvConfig({ path, override: true })
  });

const config: HardhatUserConfig = {
  solidity: "0.8.28",
  networks: {
    localhost: {
      url: "http://127.0.0.1:8545",
      accounts: {
        mnemonic: process.env.MNEMONIC || TEST_MNEMONIC
      }
    },
    base: {
      url: env("BASE_RPC_URL"),
      accounts: {
        mnemonic: env("MNEMONIC", TEST_MNEMONIC)
      }
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_KEY
  },
  sourcify: {
    enabled: true
  },
  defaultNetwork: "localhost"
};

export default config;
