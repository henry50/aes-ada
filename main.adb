with Ada.Text_IO; use Ada.Text_IO;
with AES; use AES;

procedure Main is
    Input: Input_Buffer(0..35) := (others => Byte(44));
    K: AES_128_Key := (others => Byte(55));
    IV: Init_Vector := (others => Byte(66));
    Output: Output_Buffer := AES_CBC_128(Input, K, IV, Encrypt);
begin
     null;
end Main;