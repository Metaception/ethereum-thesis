pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract etherPrice is usingOraclize
{
	string public ETHCAD;

	event newOraclizeQuery(string description);
	event newEtherPrice(string price);

	function etherPrice()
	{
		oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
		update();
	}

	function __callback(bytes32 myid, string result, bytes proof)
	{
		if (msg.sender != oraclize_cbAddress()) throw;
		ETHCAD = result;
		newEtherPrice(ETHCAD);
	}

	function update() payable
	{
		if (oraclize.getPrice("URL") > this.balance)
		{
			newOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
		}
		else
		{
			newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
			oraclize_query(60, "URL", "json(https://api.kraken.com/0/public/Ticker?pair=ETHCAD).result.XETHZCAD.c.0");
		}
	}
}
