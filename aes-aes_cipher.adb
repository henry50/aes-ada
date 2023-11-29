with AES.Common;
package body AES.AES_Cipher is

package Common renames AES.Common;

function Cipher(St: State; Schedule: Key_Schedule) return State is
begin
    return St;
end Cipher;

function Sub_Bytes(St: State) return State is
begin
    return Common.Sub_Bytes(St, Encrypt);
end Sub_Bytes;

function Shift_Rows(St: State) return State is
begin
    return Common.Shift_Rows(St, Encrypt);
end Shift_Rows;

function Mix_Columns(St: State) return State is
begin
    return St;
end Mix_Columns;

end AES.AES_Cipher;