pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract interestCanada is usingOraclize
{
	string public rate;

	event newOraclizeQuery(string description);
	event newInterestCanada(string rate);

	function interestCanada()
	{
		update();
	}

	function __callback(bytes32 myid, string result)
	{
		if (msg.sender != oraclize_cbAddress()) throw;
		rate = result;
		newInterestCanada(rate);
	}

	function update() payable
	{
		newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
		oraclize_query("WolframAlpha", "canada real interest rate");
	}
}
