contract owned
{
	address public owner;

	/* Executed at initialization and sets the owner */
	function owned() {
		owner = msg.sender;
	}

	modifier onlyOwner {
		if (msg.sender != owner) throw;
		_;
	}

	function transferOwnership(address newOwner) onlyOwner {
		owner = newOwner;
	}

	function kill() onlyOwner {
		selfdestruct(owner);
	}
}

contract timeStamper is owned
{
	uint public time;	//Unix time

	function updateTime(uint256 newTime) onlyOwner {
		time = newTime;
	}
}
