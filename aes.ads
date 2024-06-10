package AES is    
    type Byte is mod 2**8;
    type Bytes is array (Natural range <>) of Byte;
    subtype Block_Bytes is Bytes(0..15);
    subtype Input_Buffer is Bytes;
    subtype Init_Vector is Bytes(0..15);
    subtype Output_Buffer is Bytes;
    subtype Key is Bytes;
    subtype AES_128_Key is Key(0..15);
    subtype AES_192_Key is Key(0..23);
    subtype AES_256_Key is Key(0..31);
    type Operation is (Encrypt, Decrypt);

    function AES_Block_128(Input: Block_Bytes; K: AES_128_Key; Op: Operation) return Block_Bytes;
    function AES_Block_192(Input: Block_Bytes; K: AES_192_Key; Op: Operation) return Block_Bytes;
    function AES_Block_256(Input: Block_Bytes; K: AES_256_Key; Op: Operation) return Block_Bytes;

    function AES_CBC_128(Input: Input_Buffer; K: AES_128_Key; IV: Init_Vector; Op: Operation) return Output_Buffer;
    function AES_CBC_192(Input: Input_Buffer; K: AES_192_Key; IV: Init_Vector; Op: Operation) return Output_Buffer;
    function AES_CBC_256(Input: Input_Buffer; K: AES_256_Key; IV: Init_Vector; Op: Operation) return Output_Buffer;

    procedure Run_Tests;

private
    Nb: constant Natural := 4;
    type State_Row is mod 4;
    type State_Col is mod Nb;
    type State is array(State_Row, State_Col) of Byte;
    function "xor"(Left, Right: State) return State;
    type States is array(Natural range <>) of State;
    subtype Round_Key is Bytes(0..4*Nb-1); -- Nb lots of 4-byte words
    type Key_Schedule is array(Natural range <>) of Round_Key;
    subtype S_Box is Bytes(0..255);
end AES;