private package AES.Inv_Cipher is
    function Inv_Cipher(St: State; K: Key) return State;
private
    function Inv_Sub_Bytes(St: State) return State;
    function Inv_Shift_Rows(St: State) return State;
    function Inv_Mix_Columns(St: State) return State;
end AES.Inv_Cipher;