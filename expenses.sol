contract owned
{
	address public owner;

	/* Executed at initialization and sets the owner */
	function owned() {
		owner = msg.sender;
	}

	/* Only the owner can access */
	modifier onlyOwner {
		if (msg.sender != owner) throw;
		_;
	}

	/* Trandfer to new owner */
	function transferOwnership(address newOwner) onlyOwner {
		owner = newOwner;
	}

	/* Destroy contract */
	function kill() onlyOwner {
		selfdestruct(owner);
	}
}

contract expenses is owned
{
	uint public total;	//Monthly expenses

	function add(uint expense) {
		total +=	expense;
	}

	function reset() onlyOwner {
		total =	0;
	}
}
