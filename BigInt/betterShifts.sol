pragma solidity ^0.4.2;

contract BigInt
{
    function compa(uint8[2] x, uint8[2] y) constant returns(int8)
    {
        /*if (x.length > y.length)
            for (uint i = y.length; i < x.length; ++i)
            {
                if (x[i] != 0)
                    return 2;
            }
        else if (x.length < y.length)
            for (uint j = x.length; j < y.length; ++j)
            {
                if (y[j] != 0)
                    return -2;
            }*/

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

    function add(uint8[2] x, uint8[2] y) constant returns(uint8[2], uint8)
    {
        uint8[2] memory sum;
        uint8 carry =   0;

        for (uint i = 0; i < x.length; ++i)
        {
            sum[i] =    x[i] + y[i] + carry;
            if (x[i] > 255 - y[i] - carry)
                carry = 1;
            else
                carry = 0;
        }

        return (sum, carry);
    }

    function sub(uint8[2] x, uint8[2] y) constant returns(uint8[2], uint8)
    {
        uint8[2] memory diff;
        uint8 borrow =  0;

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

    function leftShift(uint8[2] x) private constant returns(uint8[2])
    {
        if (compa(x, [0, 0]) == 0)
            return x;

        uint8[2] memory r;
        uint8 carry =   0;

        for (uint i = 0; i < x.length; ++i)
        {
            r[i] =  x[i] * 2 + carry;
            carry = x[i] / 128;
        }

        return r;
    }

    function rightShift(uint8[2] x) private constant returns(uint8[2])
    {
        if (compa(x, [0, 0]) == 0)
            return x;

        uint8[2] memory r;
        uint8 carry =   0;
        uint i;

        for (uint j = x.length; j > 0; --j)
        {
            i =     j - 1;
            r[i] =  x[i] / 2 + carry;
            carry = x[i] * 128;
        }

        return r;
    }

    function mod(uint8[2] x, uint8[2] m) constant returns(uint8[2])
    {
        // Check some special cases
        if (compa(m, [0, 0]) == 0)
            throw;
        if (compa(x, [0, 0]) == 0)
            return x;
        if (compa(m, x) == 0)
            return [0, 0];
        if (compa(m, x) == 1)
            return x;

        uint8[2] memory r = x;
        uint8[2] memory n = m;

        // Align most significant bit
        while (compa(x, n) == 1 && n[n.length-1] & 0x80 != 0x80)
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

    function addiMod(uint8[2] x, uint8[2] y, uint8[2] m) constant returns(uint8[2])
    {
        uint8[2] memory r = [0, 0];
        uint8 carry;

        (r, carry) =    add(x, y);

        if (carry == 0)
            r = mod(r, m);
        else
        {
            uint8[2] memory sum =   [0, 0];
            uint8[2] memory diff =  [0, 0];

            r =         mod(r, m);
            (diff, ) =  sub([255, 255], m);
            (sum, ) =   add(r, [1, 0]);

            (r, ) =     add(sum, diff);
            r =         mod(r, m);
        }
        return r;
    }
}
