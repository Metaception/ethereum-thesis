pragma solidity ^0.4.2;

contract bigInt
{
    uint max    = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint high   = 0x8000000000000000000000000000000000000000000000000000000000000000;

    function compa(uint[2] x, uint[2] y) constant returns(int8)
    {
        uint len;
        if (x.length < y.length)
            len =  x.length;
        else
            len =  y.length;

        for (uint k = 0; k < len; ++k)
        {
            if (x[len-k-1] > y[len-k-1])
                return 1;
            else if (x[len-k-1] < y[len-k-1])
                return -1;
        }

        return 0;
    }

    function add(uint[2] x, uint[2] y) constant returns(uint[2], uint)
    {
        uint[2] memory sum;
        uint carry =   0;

        for (uint i = 0; i < x.length; ++i)
        {
            sum[i] =    x[i] + y[i] + carry;
            if (x[i] > max - y[i] - carry)
                carry = 1;
            else
                carry = 0;
        }

        return (sum, carry);
    }

    function sub(uint[2] x, uint[2] y) constant returns(uint[2], uint)
    {
        uint[2] memory diff;
        uint borrow =  0;

        for (uint i = 0; i < x.length; ++i)
        {
            diff[i] =   x[i] - y[i] - borrow;
            if (x[i] < y[i] + borrow)
                borrow = 1;
            else
                borrow = 0;
        }

        return (diff, borrow);
    }

    function leftShift(uint[2] x) private constant returns(uint[2])
    {
        if (compa(x, [uint(0), 0]) == 0)
            return x;

        uint[2] memory r;
        uint carry =   0;

        for (uint i = 0; i < x.length; ++i)
        {
            r[i] =  x[i] * 2 + carry;
            carry = x[i] / high;
        }

        return r;
    }

    function rightShift(uint[2] x) private constant returns(uint[2])
    {
        if (compa(x, [uint(0), 0]) == 0)
            return x;

        uint[2] memory r;
        uint carry =   0;
        uint i;

        for (uint j = x.length; j > 0; --j)
        {
            i =     j - 1;
            r[i] =  x[i] / 2 + carry;
            carry = x[i] * high;
        }

        return r;
    }

    function mod(uint[2] x, uint[2] m) constant returns(uint[2])
    {
        // Check some special cases
        if (compa(m, [uint(0), 0]) == 0)
            throw;
        if (compa(x, [uint(0), 0]) == 0)
            return x;
        if (compa(m, x) == 0)
            return [uint(0), 0];
        if (compa(m, x) == 1)
            return x;

        uint[2] memory r = x;
        uint[2] memory n = m;

        // Align most significant bit
        while (compa(x, n) == 1 && n[n.length-1] & high != high)
            n = leftShift(n);
        if (compa(n, x) == 1)
            n = rightShift(n);

        // Subtract
        while (compa(r, m) != -1)
        {
            if (compa(r, n) != -1)
                (r,) =  sub(r, n);
            n =     rightShift(n);
        }
        return r;
    }

    function addiMod(uint[2] x, uint[2] y, uint[2] m) constant returns(uint[2])
    {
        // Check some special cases
        if (compa(m, [uint(0), 0]) == 0)
            throw;

        uint[2] memory r = [uint(0), 0];
        uint carry;

        (r, carry) =    add(x, y);

        if (carry == 0)
            r = mod(r, m);
        else
        {
            uint[2] memory sum =   [uint(0), 0];
            uint[2] memory diff =  [uint(0), 0];

            r =         mod(r, m);
            (diff, ) =  sub([max, max], m);
            (sum, ) =   add(r, [uint(1), 0]);

            (r, ) =     add(sum, diff);
            r =         mod(r, m);
        }
        return r;
    }

    function multMod(uint[2] x, uint[2] y, uint[2] m) constant returns(uint[2])
    {
        if (compa(x, [uint(0), 0]) == 0 || compa(y, [uint(0), 0]) == 0)
            return [uint(0), 0];
        if (compa(x, [uint(1), 0]) == 0)
            return y;
        if (compa(y, [uint(1), 0]) == 0)
            return x;

        // Returns: (a * b/2) mod c
        uint[2] memory t = multMod(x, rightShift(y) , m);

        // Even factor
        if ((y[0] & 1) == 0)
            return addiMod(t, t, m);
        else
            return addiMod(x, addiMod(t, t, m), m);
    }
}
