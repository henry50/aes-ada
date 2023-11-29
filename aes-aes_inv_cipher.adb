with AES.Common;

package body AES.AES_Inv_Cipher is

package Common renames AES.Common;

function Inv_Cipher(St: State; Schedule: Key_Schedule) return State is
begin
    return St;
end Inv_Cipher;

function Inv_Sub_Bytes(St: State) return State is
begin
    return Common.Sub_Bytes(St, Decrypt);
end Inv_Sub_Bytes;

function Inv_Shift_Rows(St: State) return State is
begin
    return Common.Shift_Rows(St, Decrypt);
end Inv_Shift_Rows;

function Inv_Mix_Columns(St: State) return State is
begin
    return St;
end Inv_Mix_Columns;

end AES.AES_Inv_Cipher;