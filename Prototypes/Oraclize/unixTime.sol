pragma solidity ^0.4.0;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract unixTime is usingOraclize
{
	uint public time;

	event newOraclizeQuery(string description);
	event newUnixTime(uint time);

	function unixTime()
	{
		update();
	}

	function __callback(bytes32 myid, string result)
	{
		if (msg.sender != oraclize_cbAddress()) throw;
		time = parseInt(result, 0);
		newUnixTime(time);
	}

	function update() payable
	{
		newOraclizeQuery("Oraclize query was sent, standing by for the answer..");
		oraclize_query("URL", "json(https://ntp-a1.nict.go.jp/cgi-bin/json).st");
	}
}
