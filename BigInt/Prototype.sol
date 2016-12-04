pragma solidity ^0.4.2;

contract bigInt
{
    function compa(uint8[2] x, uint8[2] y) returns(int8)
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

    function add(uint8[2] x, uint8[2] y) returns(uint8[2], uint8)
    {
        uint8[2] memory sum;
        uint8 carry =   0;

        for (uint i = 0; i < x.length; ++i)
        {
            sum[i] =    x[i] + y[i] + carry;
            if (x[i] > 255 - y[i])
                carry = 1;
            else
                carry = 0;
        }

        return (sum, carry);
    }

    function sub(uint8[2] x, uint8[2] y) returns(uint8[2], uint8)
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

    function half(uint8 x, uint8 y) internal returns(uint8[2])
    {
        uint8 carry;
        uint8 low;
        uint8 upp;
        uint8 fact;
        uint8[2] memory prod;

        fact =  y & 0xf;
        low =   (x & 0x0f) * fact;
        upp =   (x & 0xf0)/2**4 * fact;

        prod[0] =   (upp & 0xf) * 2**4 + low;

        if (prod[0] < low || prod[0] < (upp & 0xf) * 2**4)
            carry = 1;
        else
            carry = 0;

        prod[1] =    (upp & 0xf0) / 2**4 + carry;


        fact =  (y & 0xf0) / 2**4;
        low =   (x & 0x0f) * fact;
        upp =   (x & 0xf0)/2**4 * fact;

        prod[0] +=  (low & 0xf) * 2**4;

        if (prod[0] < (low & 0xf) * 2**4)
            carry = 1;
        else
            carry = 0;

        prod[1] +=  upp + (low & 0xf0) / 2**4 + carry;


        return prod;
    }

    function mul(uint8[2] x, uint8[2] y) returns(uint8[4])
    {
        uint8 carry;
        uint8 low;
        uint8 upp;
        uint8 fact;
        uint8[4] memory prod = [0, 0, 0, 0];
        uint8[2] memory temp = [0, 0];
        
        for (uint j = 0; j < y.length; ++j)
        {
            for (uint i = 0; i < x.length; ++i)
            {
                temp =          half(x[i], y[j]);
                (temp, carry) = add([prod[i+j], prod[i+1+j]], temp);
                
                prod[i+j] =       temp[0];
                prod[i+1+j] =     temp[1];
                
                if (i+2+j < prod.length)
                    prod[i+2+j] +=    carry;
            }
        }
        
        return prod;
    }

    function shift(uint8[2] x, int shft) returns(uint8[2])
    {
        uint8[2] memory r;
        uint8 carry =   0;
        uint8 s;
        
        if (shft == 0)
            return x;
        else if (compa(x, [0, 0]) == 0)
            return x;
        else if (shft > 8 || shft < -8)
            throw;
        else if (shft > 0)
        {
            s = uint8(shft);
            for (uint i = 0; i < x.length; ++i)
            {
                r[i] =  x[i] * 2**s + carry;
                carry = x[i] / 2**(8-s);
            }
        }
        else if (shft < 0)
        {
            s = uint8(shft*-1);
            for (uint j = x.length; j > 0; --j)
            {
                i =     j - 1;
                r[i] =  x[i] / 2**s + carry;
                carry = x[i] * 2**(8-s);
            }
        }

        return r;
    }

    function mod(uint8[2] x, uint8[2] m) returns(uint8[2])
    {
        uint8[2] memory r = [0, 0];

        if (compa(m, [0, 0]) == 0)
            throw;
        if (compa(m, x) == 0)
            return r;
        if (compa(m, x) == 1)
        {
            r = x;
            return r;
        }

        r = x;
        while (compa(r, m) != -1)
            (r,) = sub(r, m);

        return r;
    }

    function addiMod(uint8[2] x, uint8[2] y, uint8[2] m) returns(uint8[2])
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

    function multMod(uint8[2] x, uint8[2] y, uint8[2] m) returns(uint8[2])
    {
        if (compa(x, [0, 0]) == 0 || compa(y, [0, 0]) == 0)
            return [0, 0];
        if (compa(x, [1, 0]) == 0)
            return y;
        if (compa(y, [1, 0]) == 0)
            return x;
    
        // Returns: (a * b/2) mod c
        t = multMod(x, [ (y[1]&1)*2**4+y[0]/2, y[1]/2 ] , m);
    
        // Even factor
        if ((y[0] & 1) == 0)
            return addiMod(t, t, m);
        else
        {
            uint8[2] memory r = [0, 0];
            uint8[2] memory t = [0, 0];
            
            r = addiMod(t, t, m);
            r = addiMod(mod(x, m), r, m);
            return r;
        }
    }

    function powMod(uint8[2] b, uint8[2] e, uint8[2] m) returns (uint8[2]) {
        uint8[2] memory r = [1, 0];

        while (compa(e, [0, 0]) != 0) {
            
            if (e[0] & 1 == 1)
                r = multMod(r, e, m);   // Odd
                
            e = shift(e, -1);
            b = multMod(b, e, m); 
        }

        return r;
    }
}
