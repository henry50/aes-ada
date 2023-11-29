private package AES.AES_Inv_Cipher is
    function Inv_Cipher(St: State; Schedule: Key_Schedule) return State;
private
    function Inv_Sub_Bytes(St: State) return State;
    function Inv_Shift_Rows(St: State) return State;
    function Inv_Mix_Columns(St: State) return State;
end AES.AES_Inv_Cipher;