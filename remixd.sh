DIR=$(cd "$(dirname "$0")"; pwd)
contracts=${DIR}/contracts
echo '合约地址:' ${contracts} 

remixd -s ${contracts} --remix-ide https://remix.ethereum.org