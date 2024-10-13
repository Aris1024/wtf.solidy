const { ethers } = require('ethers');
const ALCHEMY_SEPOLIA_URL = 'https://eth-sepolia.g.alchemy.com/v2/k4c8JHnPPjmk-q8Lz1-vZ-MGKrIN5bID';
const PRIVATEKEY = '0x227dbb8586117d55284e26620bc76534dfbd2394be34cf4a09cb775d593b6f2b';


async function main() {
    const provider = new ethers.JsonRpcProvider(ALCHEMY_SEPOLIA_URL);
    const wallet = new ethers.Wallet(PRIVATEKEY, provider);
    const account = '0x5B38Da6a701c568545dCfcB03FcB875f56beddC4';
    const tokenId = 0;
    const msgHash = ethers.solidityPackedKeccak256(['address', 'uint256'], [account, tokenId]);
    console.log(`消息:${msgHash}`)
    const messageHashBytes = ethers.getBytes(msgHash);
    const signature = await wallet.signMessage(messageHashBytes);
    console.log(`签名: ${signature}`);
}

require.main == module && main()