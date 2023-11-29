package AES is    
    type Byte is mod 2**8;
    type Input_Buffer is array(Natural range <>) of Byte;
    type Init_Vector is array(0..15) of Byte;
    type Output_Buffer is array(Natural range <>) of Byte;
    type Key is array(Natural range <>) of Byte;
    subtype AES_128_Key is Key(0..127);
    subtype AES_192_Key is Key(0..191);
    subtype AES_256_Key is Key(0..255);
    type Operation is (Encrypt, Decrypt);

    function AES_CBC_128(Input: Input_Buffer; K: AES_128_Key; IV: Init_Vector; Op: Operation) return Output_Buffer;
    function AES_CBC_192(Input: Input_Buffer; K: AES_192_Key; IV: Init_Vector; Op: Operation) return Output_Buffer;
    function AES_CBC_256(Input: Input_Buffer; K: AES_256_Key; IV: Init_Vector; Op: Operation) return Output_Buffer;

private
    type Word is mod 2**32;
    type State is array(0..3, 0..3) of Byte;
    type States is array(Natural range <>) of State;
    type Round_Key is array(0..16) of Byte;
    type Key_Schedule is array(Natural range <>) of Round_Key;
    type S_Box is array(0..255) of Byte;
end AES;