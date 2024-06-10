private package AES.Cipher is
    function Cipher(St: State; K: Key) return State;
private
    function Sub_Bytes(St: State) return State;
    function Shift_Rows(St: State) return State;
    function Mix_Columns(St: State) return State;
end AES.Cipher;