private package AES.Key_Expansion is
    function Key_Expansion(K: Key) return Key_Schedule;
private
    type Word_Index is mod 4;
    type Word is array(Word_Index) of Byte;
    function "xor"(Left, Right: Word) return Word;

    Rcon: array(1..10) of Word := 
        ((1, 0, 0, 0), (2, 0, 0, 0), (4, 0, 0, 0), (8, 0, 0, 0), (16, 0, 0, 0),
         (32, 0, 0, 0), (64, 0, 0, 0), (128, 0, 0, 0), (27, 0, 0, 0), (54, 0, 0, 0));

    function Sub_Word(W: Word) return Word;
    function Rot_Word(W: Word) return Word;

    type Round_Key_Words is array(0..Nb-1) of Word;
    function Words_To_Round_Key(Ws: Round_Key_Words) return Round_Key;

end AES.Key_Expansion;