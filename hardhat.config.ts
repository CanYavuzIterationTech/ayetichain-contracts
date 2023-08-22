import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";





const config: HardhatUserConfig = {
  solidity: "0.8.19",

  networks: {
    haqq: {
      chainId: 54211,
      url: "https://rpc.eth.testedge2.haqq.network",
      accounts: {
        mnemonic: "",
        path: "m/44'/60'/0'/0",
        initialIndex: 0,
        count: 20,
        passphrase: "",
      }

    }
  }

};

export default config;
