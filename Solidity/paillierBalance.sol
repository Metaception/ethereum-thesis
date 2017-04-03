pragma solidity ^0.4.2;
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract paillierBalance is usingOraclize
{
	uint[2] balance =	[0xd19d3832318d7dce0ec8d31ca79d19d522a0bde6b33925fe75341c7313cf3f2f, 0x2e70a63515afd874dbbbf302dd7e9e1846fb68e98aad831172];
	uint[2] nSquare =	[0x4162bdd596ae3cd8d0473c4553cdaaeff3fa6b33915c57c8dd8089a04f3ceb41, 0x619a2f50bc81e3586910990d29440354cb147f87a76135115c];

	uint radix =    256;                // Size of uint
    uint half =     2**(radix/2);       // Half bitwidth
    uint low =      half - 1;           // Low mask
    uint high =     low << (radix/2);   // High mask
    uint max =      high | low;         // Max value
    uint[2] zero =  [0, 0];             // bigInt zero
    uint[2] one =   [1, 0];             // bigInt one

	uint public time;

	event newOraclizeQuery(string description);
	event newUnixTime(uint time);
	event timeStamper(uint timestamp, address sender, uint[2] balance);

	function paillierBalance()
	{
        OAR = OraclizeAddrResolverI(0x3AE18D71a6e1E0e881fDEC7457E9A2874973F075);
		//update();
	}

    function() payable {}

	function getEther() constant returns(uint)
	{
		return this.balance;
	}

	function getBalance() constant returns(uint[2])
	{
		return balance;
	}

	function getnSquare() constant returns(uint[2])
	{
		return nSquare;
	}

    // 1 means >, 0 means =, -1 means <
    function compa(uint[2] x, uint[2] y) private constant returns(int8)
    {
        /*uint len;
        if (x.length < y.length)
            len =  x.length;
        else
            len =  y.length;*/
        uint len = x.length;

        // Compare the most significant bits first
        for (uint k = 0; k < len; ++k)
        {
            if (x[len-k-1] > y[len-k-1])
                return 1;
            else if (x[len-k-1] < y[len-k-1])
                return -1;
        }

        return 0;
    }

    // Result in Sum, Carry is 1 if overflow
    function add(uint[2] x, uint[2] y) private constant returns(uint[2], uint)
    {
        uint[2] memory sum;
        uint carry;

        // Start from the least significant bits
        for (uint i = 0; i < x.length; ++i)
        {
            sum[i] =    x[i] + y[i] + carry;
            if (x[i] > max - y[i] - carry)  // Check for overflow
                carry = 1;
            else if (x[i] == max && (carry > 0 || y[i] > 0)) // Special case
                carry = 1;
            else
                carry = 0;
        }

        return (sum, carry);
    }

    // Result in Diff, Borrow is 1 if underflow
    function sub(uint[2] x, uint[2] y) private constant returns(uint[2], uint)
    {
        uint[2] memory diff;
        uint borrow;

        // Start from the least significant bits
        for (uint i = 0; i < x.length; ++i)
        {
            diff[i] =   x[i] - y[i] - borrow;
            if (x[i] < y[i] + borrow || (y[i] == max && borrow == 1))   // Check for underflow
                borrow = 1;
            else
                borrow = 0;
        }

        return (diff, borrow);
    }

    // Same effect as multipling by 2
    function leftShift(uint[2] x) private constant returns(uint[2])
    {
        if (compa(x, zero) == 0)  // Return if zero
            return x;

        uint[2] memory r;
        uint carry;

        for (uint i = 0; i < x.length; ++i)
        {
            r[i] =  (x[i] << 1) + carry;
            carry = x[i] >> (radix - 1);
        }

        return r;
    }

    // Same effect as dividing by 2
    function rightShift(uint[2] x) private constant returns(uint[2])
    {
        if (compa(x, zero) == 0)  // Return if zero
            return x;

        uint[2] memory r;
        uint carry;

        for (uint i = x.length-1; i < max ; --i)
        {
            r[i] =  (x[i] >> 1) + carry;
            carry = x[i] << (radix - 1);
        }

        return r;
    }

    // Bitwise Shift, use sign for left or right
    function shift(uint[2] x, int shft) private constant returns(uint[2])
    {
        if (shft == 0)
            return x;
        else if (compa(x, zero) == 0)
            return x;
        else if (shft > int(radix) || shft < -1*int(radix))
            throw;

        uint[2] memory r;
        uint carry;
        uint s;    // Unsigned shift
        uint i;     // Index

        if (shft > 0)   // Left
        {
            s = uint(shft);

            for (i = 0; i < x.length; ++i)
            {
                r[i] =  (x[i] << s) + carry;
                carry = x[i] >> (radix - s);
            }
        }
        else if (shft < 0)  // Right
        {
            s = uint(shft*-1);

            for (i = x.length-1; i < max ; --i)
            {
                r[i] =  (x[i] >> s) + carry;
                carry = x[i] << (radix - s);
            }
        }

        return r;
    }

    // Modulo for small, 2**(radix/2), modulus
    function modSmall(uint[2] x, uint m) private constant returns(uint)
    {
        if (m > half)       // Check Assumption
            throw;
        if (m == 0)                 // Modulus is zero
            throw;
        if (compa(x, zero) == 0)    // Dividend is zero
            return 0;

        uint a =       ((max % m) + 1) % m;    // (2**radix) % m
        uint r =       1;
        uint result =  0;

        for (uint i = 0; i < x.length; ++i)
        {
            result =    (result + ((x[i] % m) * r) % m) % m;
            r =         (r * a) % m;
        }
        return result;
    }

    // Take the modulo using bitshift and subtraction
    function mod(uint[2] x, uint[2] m) private constant returns(uint[2])
    {
        // Check some special cases
        if (compa(m, zero) == 0)  // Modulus is zero
            throw;
        if (compa(x, zero) == 0)  // Dividend is zero
            return x;
        if (compa(m, x) == 0)       // If dividend equal modulus
            return zero;
        if (compa(m, x) == 1)       // If modulus greater than dividend
            return x;
        if (m[1] == 0 && m[0] <= half)   // If modulus greater than dividend
            return [modSmall(x, m[0]), 0];

        uint[2] memory r = x;      // Remainder
        uint[2] memory n = m;      // Copy of modulus
        uint top = 2**(radix - 1);  // Highest bit

        // Align most significant bit
        while (compa(x, n) == 1 && n[n.length-1] & top != top)
            n = leftShift(n);
        if (compa(n, x) == 1)   // If modulus copy is now greater
            n = rightShift(n);

        // Subtract repeatedly until result is less than modulus
        while (compa(r, m) != -1)
        {
            if (compa(r, n) != -1)  // Subtract if modulus copy is less than
                (r,) =  sub(r, n);
            n =     rightShift(n);  // Bitshift modulus copy
        }
        return r;
    }

    // Modular addition
    function addiMod(uint[2] x, uint[2] y, uint[2] m) private constant returns(uint[2])
    {
        // Check some special cases
        if (compa(m, zero) == 0)  // If modulus is zero
            throw;

        uint[2] memory r;  // Result
        uint carry;

        (r, carry) =    add(x, y);
        r =             mod(r, m);

        if (carry == 1)     // Handle overflow
        {
            uint[2] memory sum;
            uint[2] memory diff;

            // (r + carry) % m = [(r%m+1 + carry-1-m] % m
            (diff, ) =  sub([max, max], m);
            (sum, ) =   add(r, one);

            (r, ) =     add(sum, diff);
            r =         mod(r, m);
        }

        return r;
    }

    // Double-and-add modular multiplication
    function multMod(uint[2] x, uint[2] y, uint[2] m) private constant returns(uint[2])
    {
        // Check some special cases
        if (compa(x, zero) == 0 || compa(y, zero) == 0) // One factor is zero
            return zero;
        if (compa(x, one) == 0)                         // X is 1
            return y;
        if (compa(y, one) == 0)                         // Y is 1
            return x;

        uint[2] memory r;  // Result
        uint carry;

        while(compa(y, zero) > 0)
        {
            // Check current digit in Y
            if ((y[0] & 1) == 1)
            {
                (r, carry) = add(r, x);
                if (compa(r, m) >= 0 || carry == 1)
                    (r,) = sub(r, m);
                carry = 0;
            }

            (x, carry) = add(x, x);
            if (compa(x, m) >= 0 || carry == 1)
                (x,) = sub(x, m);
            carry = 0;
            y = rightShift(y);
        }
        return r;
    }

    // Multiplication
    function mul(uint[2] x, uint[2] y) private constant returns(uint[4])
    {
        uint[4] memory xp;		// Half bit
        uint[4] memory yp;		// Half bit
        uint[8] memory temp;
        uint[4] memory prod;

        // Pad to 4-bits
        for (uint k = 0; k < x.length; ++k)
        {
            xp[2*k] =	x[k] & low;
            xp[2*k+1] =	(x[k] & high) / half;
            yp[2*k] =	y[k] & low;
            yp[2*k+1] =	(y[k] & high) / half;
        }

        // Shift and Add
        for (uint j = 0; j < yp.length; ++j)    // Bottom factor
        {
            for (uint i = 0; i < xp.length; ++i)    // Top Factor
            {
                // Lower part
                temp[i+j] +=	(xp[i] * yp[j]) & low;
                if ((temp[i+j] & high) != 0)    // Should be zero unless overflow
                {
                    temp[i+j] =     temp[i+j] & low;
                    temp[i+j+1] +=  1;
                }

                // Higher Part
                temp[i+j+1] +=	((xp[i] * yp[j]) & high) / half;
                if ((temp[i+j+1] & high) != 0)  // Should be zero unless overflow
                {
                    temp[i+j+1] =   temp[i+j+1] & low;
                    temp[i+j+2] +=  1;
                }
            }
        }

        // Reduce to 8 bits
        for (uint n = 0; n < prod.length; ++n)
        {
            prod[n] =	temp[2*n] + temp[2*n+1] * half;
        }

        return prod;
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

	function homomorphicAdd(uint[2] ciphertext)
	{
		balance =	multMod(balance, ciphertext, nSquare);
		timeStamper(time, msg.sender, balance);
	}
}
